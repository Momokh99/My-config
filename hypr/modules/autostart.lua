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
end)
