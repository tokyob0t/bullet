// Dont try this at home kids

import Bullet from "gi://Bullet";
import GLib from "gi://GLib";

const ModKey = Bullet.ModKey;
const daemon = Bullet.get_default();

const bind = (modifiers, key, on_press, on_release) => {
	const newBind = Bullet.Bind.new(modifiers, key);

	on_press && newBind.connect("pressed", on_press);
	on_release && newBind.connect("released", on_release);

	return newBind;
};

daemon.add_bind(bind(ModKey.SUPER, "y", () => print("pressed")));

daemon.start_async();

new GLib.MainLoop(null, false).run(); // cuz it segfaults????
