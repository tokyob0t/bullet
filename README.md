# Bullet

`Bullet` is a scriptable hotkeys daemon for X11. It allows you to create and manage your keybindings using your preferred programming language.

## Requirements
To build and run this project, you need the following packages:

- `meson`
- `libglib2.0-dev` (Debian) ) / `glib2` (Arch)
- `libgobject2.0-dev` (Debian) / `glib2` (Arch)
- `libx11-dev` (Debian) (Fedora) / `libx11` (Arch)

### Installation
```sh
git clone https://github.com/tokyob0t/bullet.git
cd bullet/src
meson setup --prefix /usr build
meson install -C build
```

### Uninstallation
```sh
cd build
ninja uninstall
```
