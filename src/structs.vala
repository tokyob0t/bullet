namespace Bullet {
    public class Bind : Object {
        public signal void pressed();
        public signal void released();

        public ModKey modifiers { get; construct set; }
        public string key { get; construct set; }
        internal ulong keysym;
        internal int keycode; 

        public Bind(ModKey modifiers, string key) {
            this.modifiers = modifiers;
            this.key = key;
            keysym = X.string_to_keysym(key);
            keycode = HotkeyDaemon.get_default().display.keysym_to_keycode(this.keysym);
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

