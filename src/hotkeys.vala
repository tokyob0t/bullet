using X;
using GLib;

namespace Bullet {
    public HotkeyDaemon get_default() {
        return HotkeyDaemon.get_default();
    }

    public class HotkeyDaemon : Object {
        private static HotkeyDaemon _instance;

        private const uint MOD_MASK = (uint) (ModKey.SHIFT | ModKey.CTRL | ModKey.ALT | ModKey.SUPER);
        private const int GRAB_ASYNC = (int) X.GrabMode.Async;

        [CCode (cname = "XInitThreads")]
        private static extern int x_init_threads();

        [CCode (cname = "g_idle_add")]
        private static extern uint idle_add(SourceFunc function);

        internal X.Display display;
        internal X.Window root;

        public List<Bind> binds;

        private GLib.Mutex mutex = {};
        private Array<Bind> press_queue = new Array<Bind>();
        private Array<Bind> release_queue = new Array<Bind>();
        private bool dispatch_pending = false;
        private Thread<void> thread;

        private HotkeyDaemon() {
            x_init_threads();

            display = new X.Display();
            root = display.default_screen().root;
            binds = new List<Bind>();
        }

        public static HotkeyDaemon get_default() {
            if (_instance != null)
                return _instance;

            _instance = new HotkeyDaemon();

            return _instance;
        }

        public bool is_running() {
            return thread != null;
        }

        public void start_async() {
            if (thread != null)
                return;

            thread = new Thread<void>(null, _start);
        }

        public void start_sync() {
            start_async();

            MainLoop loop = new MainLoop(null, false);
            loop.run();
        }

        private void _start() {
            X.Event event = {};

            while (true) {
                display.next_event(ref event);
                handle_event(event);
            }
        }

        public bool add_bind(Bind bind) {
            if (!bind.is_valid()) {
                GLib.warning("bullet: unknown key \"%s\"", bind.key);
                return false;
            }

            int keycode = (int) display.keysym_to_keycode(bind.keysym);

            if (keycode == 0)
                return false;

            int status = display.grab_key(
                keycode,
                (uint) bind.modifiers,
                root,
                true,
                GRAB_ASYNC,
                GRAB_ASYNC
            );

            if (status != 0)
                return false;

            mutex.lock();

            bool duplicate = binds.find(bind) != null;

            bind.keycode = keycode;

            if (!duplicate)
                binds.append(bind);

            mutex.unlock();

            if (duplicate) {
                display.ungrab_key(keycode, (uint) bind.modifiers, root);
                return false;
            }

            return true;
        }

        public bool remove_bind(Bind bind) {
            mutex.lock();

            bool removed = binds.find(bind) != null;

            if (removed)
                binds.remove(bind);

            mutex.unlock();

            if (removed)
                display.ungrab_key(bind.keycode, (uint) bind.modifiers, root);

            return removed;
        }

        public void remove_all_binds() {
            mutex.lock();

            foreach (Bind bind in binds)
                display.ungrab_key(bind.keycode, (uint) bind.modifiers, root);

            binds = new List<Bind>();

            mutex.unlock();
        }

        public void handle_event(X.Event event) {
            if (event.type != X.EventType.KeyPress && event.type != X.EventType.KeyRelease)
                return;

            ModKey state = (ModKey) (event.xkey.state & MOD_MASK);

            mutex.lock();

            foreach (Bind bind in binds) {
                if (bind.keycode != (int) event.xkey.keycode || bind.modifiers != state)
                    continue;

                if (event.type == X.EventType.KeyPress)
                    press_queue.append_val(bind);
                else
                    release_queue.append_val(bind);

                break;
            }

            bool schedule = !dispatch_pending;

            if (schedule)
                dispatch_pending = true;

            mutex.unlock();

            if (schedule)
                idle_add(dispatch);
        }

        private bool dispatch() {
            mutex.lock();

            Array<Bind> presses = press_queue;
            Array<Bind> releases = release_queue;

            press_queue = new Array<Bind>();
            release_queue = new Array<Bind>();
            dispatch_pending = false;

            mutex.unlock();

            foreach (Bind bind in presses)
                bind.pressed();

            foreach (Bind bind in releases)
                bind.released();

            return false;
        }
    }
}
