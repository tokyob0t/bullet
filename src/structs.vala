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
        }

        public bool is_valid() {
            return keysym != 0;
        }
    }

    [Flags]
    public enum ModKey {
        NONE = 0,
        SHIFT = 1,
        CTRL = 4,
        ALT = 8,
        SUPER = 64,
    }
}
