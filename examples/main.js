import Bullet from "gi://Bullet";
import GLib from "gi://GLib";

const ModKey = Bullet.ModKey;
const daemon = Bullet.get_default();

const bind = (modifiers, key, on_press, on_release = null) => {
	const newBind = Bullet.Bind.new(modifiers, key);

	if (!newBind.is_valid())
		throw new Error(`unknown key: ${key}`);

	newBind.connect("pressed", on_press);

	if (on_release)
		newBind.connect("released", on_release);

	if (!daemon.add_bind(newBind))
		throw new Error(`could not grab ${modifiers} + ${key}`);

	return newBind;
};

bind(ModKey.SUPER, "y", () => print("super+y"));
bind(ModKey.SUPER | ModKey.SHIFT, "y", () => print("super+shift+y"));
bind(
	ModKey.NONE,
	"XF86AudioMute",
	() => print("mute"),
	() => print("unmute"),
);

daemon.start_async();

print("listening, press ctrl+c to stop");
new GLib.MainLoop(null, false).run();
