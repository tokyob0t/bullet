# Bullet

`Bullet` is a scriptable hotkeys daemon for X11. It lets you define and manage
keybindings from your preferred programming language, by exposing a small
GObject API over GObject-Introspection.

Bullet is a **library, not a binary**: it installs a shared library, a Vala
vapi, a GIR and a typelib. Your own script hosts the process and owns the main
loop.

## Requirements

Build dependencies:

- `meson`
- `ninja`
- `valac`
- `glib2`
- `libx11`
- `gobject-introspection` (only for the typelib)

Runtime dependencies depend on the language you pick:

| Language | Runtime       | Typelib import                    |
| -------- | ------------- | --------------------------------- |
| Python   | PyGObject     | `from gi.repository import Bullet`  |
| Lua      | `lgi`         | `lgi.require("Bullet")`            |
| GJS      | `gjs`         | `import Bullet from "gi://Bullet"`  |

## Build

```sh
meson setup --prefix /usr build
meson compile -C build
meson install -C build
```

Uninstall:

```sh
ninja -C build uninstall
```

Build without installing, for a quick test:

```sh
meson setup build
meson compile -C build
```

## Usage

### Concepts

- `Bullet.get_default()` returns the singleton `HotkeyDaemon`. It owns the
  connection to the X display and is created lazily on first use.
- `Bullet.Bind.new(modifiers, key)` describes a single binding. `key` is any
  X keysym name (`"y"`, `"space"`, `"Return"`, `"XF86AudioMute"`, ...).
  `is_valid()` reports whether the key name resolved.
- `daemon.add_bind(bind)` grabs the key on the root window and returns whether
  the grab succeeded. It returns `false` if another client already owns the
  combination.
- Each `Bind` emits `pressed` and `released`.
- `daemon.start_async()` spawns a thread that pumps X events.
  `daemon.start_sync()` does the same and then runs the main loop for you.

`pressed` and `released` are always emitted **on the thread running the main
loop**, so handlers are free to call into your language runtime. You still need
a running main loop for them to fire: either call `start_sync()` or run your own
loop after `start_async()`, as all the examples below do.

Modifiers are matched exactly: a binding on `SUPER` does not trigger when you
press `SUPER` + `SHIFT`. Combine them explicitly with `|`.

### Python

```python
from gi.repository import Bullet, GLib

daemon = Bullet.get_default()

mute = Bullet.Bind.new(Bullet.ModKey.NONE, "XF86AudioMute")
mute.connect("pressed", lambda *_: print("mute"))
mute.connect("released", lambda *_: print("unmute"))
daemon.add_bind(mute)

volume = Bullet.Bind.new(Bullet.ModKey.SUPER | Bullet.ModKey.SHIFT, "v")
volume.connect("pressed", lambda *_: print("volume up"))
daemon.add_bind(volume)

daemon.start_async()
GLib.MainLoop(None, False).run()
```

Run it with:

```sh
python3 examples/main.py
```

### Lua

```lua
local lgi = require("lgi")
local Bullet = lgi.require("Bullet")
local GLib = lgi.require("GLib")

local ModKey = Bullet.ModKey
local daemon = Bullet.get_default()

local bind = Bullet.Bind.new(ModKey.SUPER, "y")
bind.on_pressed = function() print("super+y") end
daemon:add_bind(bind)

daemon:start_async()
GLib.MainLoop():run()
```

Run it with:

```sh
lua examples/init.lua
```

### GJS

```js
import Bullet from "gi://Bullet";
import GLib from "gi://GLib";

const daemon = Bullet.get_default();

const bind = Bullet.Bind.new(Bullet.ModKey.SUPER, "y");
bind.connect("pressed", () => print("super+y"));
daemon.add_bind(bind);

daemon.start_async();
new GLib.MainLoop(null, false).run();
```

Run it with:

```sh
gjs -m examples/main.js
```

### Unbinding

```python
binds = [Bullet.Bind.new(Bullet.ModKey.SUPER, "y")]

for bind in binds:
    daemon.add_bind(bind)

# later
for bind in binds:
    daemon.remove_bind(bind)   # also ungrabs the key

daemon.remove_all_binds()
```

## Notes

- X11 only. There is no Wayland backend.
- A grab is exclusive: if your window manager or another hotkey daemon already
  owns the same combination, `add_bind` returns `false`.
- The daemon shares the default X display and never closes it; its lifetime is
  the lifetime of the process. Unbind explicitly if you need the keys back.

## License

GPL-3.0. See [LICENSE](LICENSE).
