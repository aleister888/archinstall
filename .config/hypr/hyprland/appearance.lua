hl.env("GTK_THEME", "Gruvbox-Dark")
hl.env("GDK_BACKEND", "wayland,x11,*")

local config = require("hyprland/config")

hl.config({
	general = {
		gaps_in = config.gaps_in,
		gaps_out = config.gaps_out,

		border_size = config.border_size,
		resize_on_border = false,
		["col.active_border"] = "rgb(b8bb26)",
		["col.inactive_border"] = "rgb(1d2021)",

		layout = "master",
	},

	decoration = {
		rounding = config.rounding,

		shadow = {
			enabled = true,
			range = 12,
			render_power = 2,
			color = "rgb(151515)",
		},

		blur = {
			enabled = true,
			size = 4,
			passes = 2,
			noise = 0.01,
			contrast = 0.75,
			brightness = 0.66,
			vibrancy = 0.0,
			vibrancy_darkness = 1.0,
			special = true,
		},
	},

	plugin = {
		hyprbars = {
			enabled = true,
			bar_height = config.hyprbar_height,

			["col.text"] = "rgb(ebdbb2)",
			bar_text_align = "center",

			bar_color = "rgb(1D2021)",
			bar_precedence_over_border = true,

			bar_buttons_alignment = "left",
			bar_padding = 9,
			bar_button_padding = 6,

			hl.plugin.hyprbars.add_button({
				bg_color = "rgb(cc241d)",
				fg_color = "rgb(ebdbb2)",
				size = 15,
				icon = "",
				action = "hyprctl dispatch 'hl.dsp.window.close({ window = activewindow })'",
			}),
			hl.plugin.hyprbars.add_button({
				bg_color = "rgb(d79921)",
				fg_color = "rgb(ebdbb2)",
				size = 15,
				icon = "",
				action = "hyprctl dispatch 'hl.dsp.window.fullscreen({mode = 1})'",
			}),
			hl.plugin.hyprbars.add_button({
				bg_color = "rgb(98971a)",
				fg_color = "rgb(ebdbb2)",
				size = 15,
				icon = "",
				action = "~/.dotfiles/bin/hyprland/switch-scratchpad",
			}),

			bar_text_size = 20,
			bar_text_font = "Fira Sans Compressed",
			bar_text_weight = 500,

			bar_part_of_window = false,
			bar_blur = false,
		},

		hyprfocus = {
			enable = true,
			keyboard_focus_animation = "slide",
			slide_height = 10,
		},
	},

	animations = {
		enabled = true,
		hl.curve(
			"easeInQuart",
			{ type = "bezier", points = { { 0.5, 0 }, { 0.75, 0 } } }
		),
		hl.curve(
			"easeOutQuart",
			{ type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } }
		),

		hl.animation({
			leaf = "layers",
			enabled = true,
			speed = 1.5,
			bezier = "easeOutQuart",
			style = "slidefade 20%",
		}),
		hl.animation({
			leaf = "windows",
			enabled = true,
			speed = 0.5,
			bezier = "easeOutQuart",
			style = "slidefade 20%",
		}),
		hl.animation({
			leaf = "border",
			enabled = false,
		}),
		hl.animation({
			leaf = "workspaces",
			enabled = true,
			speed = 1.5,
			bezier = "easeOutQuart",
			style = "slide",
		}),
		hl.animation({
			leaf = "specialWorkspace",
			enabled = true,
			speed = 1.5,
			bezier = "easeOutQuart",
			style = "slidevert 20%",
		}),
		hl.animation({
			leaf = "hyprfocusIn",
			enabled = true,
			speed = 1,
			bezier = "easeOutQuart",
		}),
		hl.animation({
			leaf = "hyprfocusOut",
			enabled = true,
			speed = 1,
			bezier = "easeOutQuart",
		}),
	},
})
