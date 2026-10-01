local lgi = require("lgi")
local Bullet = lgi.require("Bullet")
local GLib = lgi.require("GLib")

local ModKey = Bullet.ModKey
local daemon = Bullet.get_default()

local function bind(modifiers, key, on_press, on_release)
	local new_bind = Bullet.Bind.new(modifiers, key)

	if not new_bind:is_valid() then
		error("unknown key: " .. key)
	end

	new_bind.on_pressed = on_press

	if on_release then
		new_bind.on_released = on_release
	end

	if not daemon:add_bind(new_bind) then
		error("could not grab " .. tostring(modifiers) .. " + " .. key)
	end

	return new_bind
end

bind(ModKey.SUPER, "y", function() print("super+y") end)
bind(ModKey.SUPER | ModKey.SHIFT, "y", function() print("super+shift+y") end)
bind(
	ModKey.NONE,
	"XF86AudioMute",
	function() print("mute") end,
	function() print("unmute") end
)

daemon:start_async()

print("listening, press ctrl+c to stop")
GLib.MainLoop():run()
