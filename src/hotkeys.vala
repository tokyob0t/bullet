using X;
using GLib;

namespace Bullet {
    public class HotkeyDaemon : Object {
        internal X.Display display;
        internal X.Window root;

        public List<Bind> binds;

        public HotkeyDaemon() {
            display = new X.Display();
            root = display.default_screen().root;
        }

        public void start_async() {
            Thread<void> _ = new Thread<void>(null, _start);
        }

        public void start_sync() {
            start_async();
            new GLib.MainLoop().run();
        }

        private void _start(){
            X.Event event = {};

            while (true) {
                display.next_event(ref event);
                try {
                    handle_event(event);
                } catch (Error err) {
                    critical(err.message);
                }
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

        public void handle_event(X.Event event) throws Error {
            if (event.type == X.EventType.KeyPress || event.type == X.EventType.KeyRelease) {
                foreach (Bind b in binds) {
                    if (b.keycode == event.xkey.keycode && (event.xkey.state & b.modifiers) == b.modifiers) {
                        if (event.type == X.EventType.KeyPress && b.press_callback != null)
                            b.press_callback();

                        if (event.type == X.EventType.KeyRelease && b.release_callback!= null)
                            b.release_callback();

                        return;
                    }
                }
            }
        }
    }
}

