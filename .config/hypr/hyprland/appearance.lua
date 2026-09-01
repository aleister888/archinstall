hl.env("GTK_THEME", "Gruvbox-Dark")
hl.env("GDK_BACKEND", "wayland,x11,*")

local config = require("hyprland/config")

hl.config({
	general = {
		gaps_in = config.gaps_in,
		gaps_out = config.gaps_out,

		border_size = config.border_size,
		resize_on_border = false,
		["col.active_border"] = "rgba(B8BB26FF)",
		["col.inactive_border"] = "rgba(1D2021FF)",

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
	},
})
