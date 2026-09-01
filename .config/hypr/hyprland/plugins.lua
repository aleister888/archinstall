local config = require("hyprland/config")
local decorations_enabled = true

local repo_dir           = os.getenv("REPO_DIR") or (os.getenv("HOME") .. "/.dotfiles")
local marker             = repo_dir .. "/.hyprland_plugins_enabled"
local waybar_css_src_on  = repo_dir .. "/assets/configs/apps/waybar/box_decorations.css"
local waybar_css_src_off = repo_dir .. "/assets/configs/apps/waybar/box_simple.css"
local waybar_css_dst     = os.getenv("HOME") .. "/.config/waybar/waybar_box.css"

local function plugins_enabled()
	local f = io.open(marker, "r")

	if f then
		f:close()
		return true
	end

	return false
end

if plugins_enabled() then
	local no_bar = function(match)
		hl.window_rule({
			match = match,
			["hyprbars:no_bar"] = true,
		})
	end

	no_bar({ class = "^(dragon-drop)$" })
	no_bar({ fullscreen_state_client = 2 })
	no_bar({ workspace = config.scratch_workspace })
	no_bar({ class = "^((W|w)aydroid.*)$" })
	no_bar({ class = "^(hyprpolkitagent)$" })
	no_bar({ class = "^(Minecraft.*)$" })

	hl.config({
		plugin = {
			hyprbars = {
				enabled = true,
				bar_height = config.hyprbar_height,

				["col.text"] = "rgba(ebdbb2ff)",
				bar_text_align = "center",

				bar_color = "rgba(1d2021ff)",
				bar_precedence_over_border = true,

				bar_buttons_alignment = "left",
				bar_padding = 9,
				bar_button_padding = 6,

				hl.plugin.hyprbars.add_button({
					bg_color = "rgba(cc241dff)",
					fg_color = "rgba(ebdbb2ff)",
					size = 15,
					icon = "",
					action = "hyprctl dispatch 'hl.dsp.window.close({ window = activewindow })'",
				}),
				hl.plugin.hyprbars.add_button({
					bg_color = "rgba(d79921ff)",
					fg_color = "rgba(ebdbb2ff)",
					size = 15,
					icon = "",
					action = "hyprctl dispatch 'hl.dsp.window.fullscreen({mode = 1})'",
				}),
				hl.plugin.hyprbars.add_button({
					bg_color = "rgba(98971aff)",
					fg_color = "rgba(ebdbb2ff)",
					size = 15,
					icon = "",
					action = "~/.dotfiles/bin/hyprland/switch-scratchpad",
				}),

				bar_text_size = 20,
				bar_text_font = "Fira Sans Compressed",
				bar_text_weight = 500,

				bar_part_of_window = true,
				bar_blur = false,
			},

			hyprfocus = {
				enable = true,
				keyboard_focus_animation = "slide",
				slide_height = 10,
			},
		},
	})
end

local function toggle_decorations()
	if decorations_enabled then
		hl.config({
			general = { gaps_in = 0, gaps_out = 0, border_size = 4 },
			decoration = { rounding = 0, shadow = { enabled = false } },
			animations = { enabled = false },
		})
		os.execute(string.format('rm -f "%s"', waybar_css_dst))
		os.execute(
			string.format('cp -f "%s" "%s"', waybar_css_src_off, waybar_css_dst)
		)

		if plugins_enabled() then
			hl.config({
				plugin = {
					-- bug: window top pixels cant be clicked if bar_height is not set to 0
					hyprbars = { enabled = false, bar_height = 0 },
					hyprfocus = { enable = false },
				},
			})
		end
	else
		hl.config({
			general = { gaps_in = config.gaps_in, gaps_out = config.gaps_out, border_size = config.border_size },
			decoration = { rounding = config.rounding, shadow = { enabled = true } },
			animations = { enabled = true },
		})
		os.execute(string.format('rm -f "%s"', waybar_css_dst))
		os.execute(
			string.format('cp -f "%s" "%s"', waybar_css_src_on, waybar_css_dst)
		)

		if plugins_enabled() then
			hl.config({
				plugin = {
					hyprbars = { enabled = true, bar_height = config.hyprbar_height },
					hyprfocus = { enable = true },
				},
			})
		end
	end

	os.execute("pkill -sigusr2 waybar 2>/dev/null || true")
	decorations_enabled = not decorations_enabled
end

hl.bind(config.mod .. " + F12", function()
	toggle_decorations()
end)
