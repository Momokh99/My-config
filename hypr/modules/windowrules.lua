hl.window_rule({
	name = "impala_rules",
	match = { class = "^(impala)$" },
	float = true,
	center = true,
	size = { 600, 550 }, -- Some Lua-Hyprland iterations prefer explicit width/height keys
})

hl.window_rule({
	name = "bluetui_rules",
	match = { class = "^(bluetui-floating)$" },
	float = true,
	center = true,
	size = { 600, 550 },
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
local noAnimWofi = hl.layer_rule({
	name = "no-anim-wofi",
	match = { namespace = "^wofi$" },
	no_anim = true,
})
noAnimWofi:set_enabled(true)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
