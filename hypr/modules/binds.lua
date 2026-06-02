---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "dolphin"
local menu = "wofi"
local browser = "helium-browser"
local notification = "mako"

-- Gap defaults
gaps = { in_size = 5, out_size = 8 }

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local enter = "Return" -- Set enter Variable

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. "+" .. enter, hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + SHIFT + Q",
	hl.dsp.exec_cmd([[sh -c 'command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit']])
)
-- Restart Hyprland with Ctrl + Alt + R
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("hyprctl dispatch restart"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("kitty -e opencode"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("kitty --class impala -e impala"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

-- Keybind to lock the screen (Super + L)
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- An array of the keys on the AZERTY top row from 1 to 0
local azerty_keys = {
	"ampersand",
	"eacute",
	"quotedbl",
	"apostrophe",
	"parenleft",
	"minus",
	"egrave",
	"underscore",
	"ccedilla",
	"agrave",
}
for i = 1, 10 do
	local key = azerty_keys[i]
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Toggle Waybar on and off with Super + Escape
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("pkill waybar || waybar"))

-- Toggle gaps, rounding, and border with Ctrl + Escape
hl.bind(
	"CTRL + Escape",
	hl.dsp.exec_cmd(
		[[sh -c 'cur=$(hyprctl getoption general:gaps_in | awk "{print \$4}"); if [ "$cur" = "0" ]; then hyprctl eval "hl.config({ general = { gaps_in = ]] .. gaps.in_size .. [[, gaps_out = ]] .. gaps.out_size .. [[, rounding = 10, border_size = 2 } })"; else hyprctl eval "hl.config({ general = { gaps_in = 0, gaps_out = 0, rounding = 0, border_size = 0 } })"; fi']]
	)
)

-- Scroll through existing workspaces with ALT + Left/Right Arrow
hl.bind("CTRL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + Left", hl.dsp.focus({ workspace = "e-1" }))

-- Scroll through existing workspaces with ALT + Left/Right Arrow
hl.bind("CTRL + SHIFT + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CTRL + SHIFT + Left", hl.dsp.focus({ workspace = "m-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, ["repeat"] = true } -- fixed flag
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, ["repeat"] = true } -- fixed flag
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, ["repeat"] = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, ["repeat"] = true }
)

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, ["repeat"] = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, ["repeat"] = true }) -- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

---------------------
---- SCREENSHOTS ----
---------------------

local screenshotDir = os.getenv("HOME") .. "/Pictures/screenshoot"
os.execute("mkdir -p " .. screenshotDir)

hl.bind("Print", hl.dsp.exec_cmd("grim " .. screenshotDir .. "/$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" ' .. screenshotDir .. "/$(date +'%Y-%m-%d_%H-%M-%S').png"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
