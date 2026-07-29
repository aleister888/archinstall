hl.window_rule({ -- Portal XDG xwayland
	name = "gtk_portal_x11_spanish",
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^(Abrir .*)$",
		xwayland = true,
	},
	border_size = 0,
	no_shadow = true,
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.75)" },
})

hl.window_rule({ -- Portal XDG xwayland
	name = "gtk_portal_x11_english",
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^(Open .*)$",
		xwayland = true,
	},
	border_size = 0,
	no_shadow = true,
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.75)" },
})

hl.window_rule({ -- Portal XDG xwayland
	name = "gtk_portal_x11_popup",
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^(xdg-desktop-portal-gtk)$",
		xwayland = true,
	},
	no_anim = true,
	rounding = 0,
	move = { "(cursor_x+10)", "(cursor_y+10)" },
})

hl.window_rule({
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^()$",
	},
	no_shadow = true,
	border_size = 0,
})

hl.window_rule({
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^(Choose a folder to clone .*)$",
	},
	no_shadow = true,
	border_size = 0,
})

hl.window_rule({
	match = {
		class = "^(Xdg-desktop-portal-gtk)$",
		title = "^(Project Location)$",
	},
	no_shadow = true,
	border_size = 0,
})

hl.window_rule({
	match = { class = "^(xdg-desktop-portal-gtk)$" },
	tag = "+1/2",
})
