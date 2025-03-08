using X;
using GLib;

namespace Bullet {
    // Mimic astal get_default function
    public HotkeyDaemon get_default() {
        return HotkeyDaemon.get_default();
    }

    public class HotkeyDaemon : Object {
        private static HotkeyDaemon _instance;
        internal X.Display display;
        internal X.Window root;

        public List<Bind> binds;

        private HotkeyDaemon() {
            display = new X.Display();
            root = display.default_screen().root;
        }

        public static HotkeyDaemon get_default() {
            if (_instance != null) 
                return _instance;

            HotkeyDaemon i = new HotkeyDaemon();
            _instance = i;

            return i;
        }

        public void start_async() {
            Thread<void> _ = new Thread<void>(null, _start);
        }

        public void start_sync() {
            start_async();
            new MainLoop(null, false).run();
        }

        private void _start(){
            X.Event event = {};

            while (true) {
                display.next_event(ref event);
                handle_event(event);
            }
        }

        public void add_bind(Bind bind) {
            display.grab_key(
                bind.keycode,
                bind.modifiers,
                root,
                true,
                X.GrabMode.Async,
                X.GrabMode.Async
            );

            binds.append(bind);
        }

        public void handle_event(X.Event event) {
            if (event.type == X.EventType.KeyPress || event.type == X.EventType.KeyRelease) {
                foreach (Bind b in binds) {
                    if (b.keycode == event.xkey.keycode && (event.xkey.state & b.modifiers) == b.modifiers) {
                        if (event.type == X.EventType.KeyPress)
                            b.pressed();

                        if (event.type == X.EventType.KeyRelease)
                            b.released();

                        return;
                    }
                }
            }
        }
    }
}

