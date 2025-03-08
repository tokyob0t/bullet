from gi.repository import Bullet, GLib

ModKey = Bullet.ModKey
daemon = Bullet.get_default()


def bind(modifiers, key, on_press=None, on_release=None):
    new_bind = Bullet.Bind.new(modifiers, key)

    if on_press:
        new_bind.connect('pressed', on_press)

    if on_release:
        new_bind.connect('released', on_release)

    return new_bind


daemon.add_bind(bind(ModKey.SUPER, 'y', lambda _: print('pressed')))

daemon.start_async()
GLib.MainLoop(None, False).run()
