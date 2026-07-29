-- About
hl.window_rule({
	match = {
		class = "^(firefox)",
		title = "^(Acerca de Mozilla Firefox)$",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.3)", "(monitor_h*0.35)" },
})

hl.window_rule({
	match = {
		class = "^(librewolf)",
		title = "^(About LibreWolf)$",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.3)", "(monitor_h*0.35)" },
})

-- Version Warning
hl.window_rule({
	match = {
		class = "^(firefox)",
		title = "^(You’ve launched an older version of Firefox)$",
	},
	tag = "+1/2",
})
hl.window_rule({
	match = {
		class = "^(librewolf)",
		title = "^(You’ve launched an older version of LibreWolf)$",
	},
	tag = "+1/2",
})

-- Privacy
hl.window_rule({
	name = "whatsapp_firefox",
	match = {
		class = "^(firefox)$",
		title = "^(WhatsApp — Mozilla Firefox)$",
	},
	no_screen_share = true,
})
hl.window_rule({
	name = "whatsapp_librewolf",
	match = {
		class = "^(librewolf)$",
		title = "^(WhatsApp — LibreWolf)$",
	},
	no_screen_share = true,
})

-- Unsync fullscreen state
hl.window_rule({
	match = { class = "^(firefox)$" },
	sync_fullscreen = false,
})
hl.window_rule({
	match = { class = "^(librewolf)$" },
	sync_fullscreen = false,
})
hl.window_rule({
	match = { initial_class = "^(Tor Browser)$" },
	suppress_event = "fullscreen",
	sync_fullscreen = false,
})
