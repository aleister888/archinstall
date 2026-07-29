hl.window_rule({
	name = "vlc",
	match = { class = "^(vlc)$" },
	suppress_event = "fullscreen maximize",
})

-- Idle inhibit
hl.window_rule({
	match = { class = "^(mpv)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { class = "^(org.kde.gwenview)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(.*HBO Max — Mozilla Firefox)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(.*HBO Max — LibreWolf)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(.*YouTube — Mozilla Firefox)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(.*YouTube — LibreWolf)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(Netflix — Mozilla Firefox)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(Netflix — LibreWolf)$" },
	idle_inhibit = "focus",
})
hl.window_rule({
	match = {
		title = "^(La isla de las tentaciones.* — Mozilla Firefox)$",
	},
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(La isla de las tentaciones.* — LibreWolf)$" },
	idle_inhibit = "focus",
})
