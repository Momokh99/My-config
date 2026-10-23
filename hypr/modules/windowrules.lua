-- Floating TUI panels (Wi-Fi / Bluetooth): docked flush at the right edge,
-- inset 60 px from top and bottom to clear the bar, sharp corners on the
-- docked edge, and slide in/out from the right instead of the global popin.
local function right_panel(name, class)
	hl.window_rule({
		name = name,
		match = { class = class },
		float = true,
		size = { 600, "monitor_h-120" }, -- 60 px off top and bottom
		-- window_w/window_h resolve to the goal size (set by `size` above)
		move = { "(monitor_w-window_w)", "60" }, -- flush with the right edge
		rounding = 6, -- slightly rounded corners (right side is flush with the screen)
		opacity = "0.9 override", -- make it absolute, independent of active/inactive state
		animation = "slide right",
	})
end

right_panel("wifitui_rules", "^(wifitui)$")
right_panel("bluetui_rules", "^(bluetui-floating)$")

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
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
