from gi.repository import Bullet, GLib

ModKey = Bullet.ModKey
daemon = Bullet.get_default()


def bind(modifiers, key, on_press, on_release=None):
    new_bind = Bullet.Bind.new(modifiers, key)

    if not new_bind.is_valid():
        raise ValueError(f"unknown key: {key}")

    new_bind.connect("pressed", on_press)

    if on_release:
        new_bind.connect("released", on_release)

    if not daemon.add_bind(new_bind):
        raise RuntimeError(f"could not grab {modifiers}+{key}")

    return new_bind


bind(ModKey.SUPER, "y", lambda *_: print("super+y"))
bind(ModKey.SUPER | ModKey.SHIFT, "y", lambda *_: print("super+shift+y"))
bind(
    ModKey.NONE,
    "XF86AudioMute",
    lambda *_: print("mute"),
    lambda *_: print("unmute"),
)

daemon.start_async()

print("listening, press ctrl+c to stop")
GLib.MainLoop(None, False).run()
