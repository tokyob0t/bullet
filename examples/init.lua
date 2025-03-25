local lgi = require("lgi")
local Bullet = lgi.require("Bullet")
local GLib = lgi.require("GLib")

local ModKey = Bullet.ModKey
local daemon = Bullet.get_default()

local function bind(modifiers, key, on_press, on_release)
	local new_bind = Bullet.Bind.new(modifiers, key)

	new_bind.on_pressed = on_press or function() end
	new_bind.on_released = on_release or function() end

	return new_bind
end

daemon:add_bind(bind(ModKey.SUPER, "y", function()
	print("pressed")
end))

daemon:add_bind(bind(ModKey.NONE, "XF86AudioMute", function()
	print("pressed")
end))

daemon:start_async()
GLib.MainLoop():run()
