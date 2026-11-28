-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("waybar & mako & hypridle")
	-- awww-daemon is started by set-theme, which also restores the last wallpaper.
	hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/set-theme --restore &")
	-- Restart (not start) so the agent belongs to this session: the unit is shared
	-- across logins and may still carry Plasma's WAYLAND_DISPLAY from a previous session.
	hl.exec_cmd("systemctl --user restart plasma-polkit-agent")
end)
