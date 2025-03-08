using X;

namespace Bullet {
    public class Bind : Object {
        public ModKey modifiers { get; construct set; }
        public string key { get; construct set; }
        public Callback? press_callback { get; construct set; }
        public Callback? release_callback { get; construct set; }
        public ulong keysym { get; private set; }
        public int keycode { get; private set; }

        public Bind(ModKey modifiers, string key, Callback? press_callback, Callback? release_callback) {
            this.modifiers = modifiers;
            this.key = key;
            this.press_callback = press_callback;
            this.release_callback = release_callback;
            keysym = X.string_to_keysym(key);
            keycode = new HotkeyDaemon().display.keysym_to_keycode(this.keysym);
        }
    }

    [Flags]
    public enum ModKey {
        SHIFT = 1,
        CTRL = 4,
        ALT = 8,
        SUPER = 64, 
    }
}

