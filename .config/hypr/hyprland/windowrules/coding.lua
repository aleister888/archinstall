-- DBeaver
hl.window_rule({
	match = { class = "^(DBeaver)$" },
	workspace = "11",
	fullscreen_state = "0",
})
hl.window_rule({
	name = "dbeaver_loading",
	match = {
		class = "^(java)$",
		title = "^(Dbeaver)$",
	},
	workspace = "11",
	float = true,
	center = true,
	no_initial_focus = true,
	size = { 0, 0 }, -- Dejamos que tome el tamaño mínimo
})

hl.window_rule({
	match = { class = "^(GitHub Desktop)$" },
	workspace = "12",
})

-- Weka
hl.window_rule({
	match = {
		class = "^(weka-gui-GUIChooser)$",
		title = "^(Weka GUI Chooser)$",
	},
	tile = true,
})
hl.window_rule({
	match = {
		class = "^(weka-gui-GUIChooser)$",
		title = "^(win0)$",
	},
	center = true,
})
hl.window_rule({
	match = {
		class = "^(weka-gui-GUIChooser)$",
		title = "^(weka.gui.GenericObjectEditor)$",
	},
	float = true,
})
hl.window_rule({
	match = {
		class = "^(weka-gui-GUIChooser)$",
		title = "^(.*focusableSwingPopup.*)$",
	},
	rounding = 0,
	float = true,
})
hl.window_rule({
	name = "weka_popup",
	match = {
		class = "^(weka-gui-GUIChooser)",
		title = "^(win.*)$",
	},
	float = true,
	rounding = 0,
	move = { "cursor_x", "cursor_y" },
})

-- Jetbrains
hl.window_rule({
	match = { class = "^(jetbrains-idea-ce)$" },
	workspace = "12",
})
hl.window_rule({
	match = {
		class = "^(jetbrains-idea-ce)$",
		title = "^(Congratulations)$",
	},
	dim_around = true,
})
hl.window_rule({
	name = "jebtrains_popup",
	match = {
		class = "^(jetbrains-idea-ce)$",
		title = "^(win[0-9]*)$",
	},
	float = true,
	no_blur = true,
	border_size = 0,
	no_shadow = true,
	no_anim = true,
	rounding = 0,
	no_initial_focus = true,
})

-- Eclipse
hl.window_rule({
	match = { class = "^(Eclipse)$" },
	workspace = "12",
	fullscreen_state = "0",
})
hl.window_rule({
	match = {
		class = "^(Eclipse)$",
		title = "^(.*Project)$",
	},
	tag = "+2/3",
})
hl.window_rule({
	match = {
		class = "^(Eclipse)$",
		title = "^(Eclipse Marketplace )$",
	},
	tag = "+2/3",
})
hl.window_rule({
	match = {
		class = "^(Eclipse)$",
		title = "^(Problem .*)$",
	},
	tag = "+2/3",
})
hl.window_rule({
	match = {
		class = "^(Eclipse)$",
		title = "^(Saving .*)$",
	},
	float = true,
})
hl.window_rule({
	match = {
		class = "^(Eclipse)$",
		title = "^(Eclipse IDE )$",
	},
	float = true,
})
hl.window_rule({
	name = "eclipse_storage",
	match = {
		class = "^(Eclipse)$",
		title = "^(Secure Storage )$",
	},
	tag = "+center",
	size = { "(monitor_w*0.3)", "(monitor_h*0.2)" },
	no_screen_share = true,
})
hl.window_rule({
	name = "eclipse_loading",
	match = {
		class = "^(java)$",
		title = "^(Eclipse)$",
	},
	workspace = "12",
	float = true,
	center = true,
	no_initial_focus = true,
	size = { 0, 0 },
}) -- Dejamos que tome el tamaño mínimo

--hl.window_rule({
--	match = { class = "^(VSCodium)$" },
--	workspace = "12",
--	center = true,
--})
--hl.window_rule({
--	match = { class = "^(Codium)$" },
--	workspace = "12",
--	center = true,
--})
--hl.window_rule({
--	match = { class = "^(codium)$" },
--	workspace = "12",
--	center = true,
--})
--hl.window_rule({
--	match = { class = "^(Code)$" },
--	workspace = "11",
--	center = true,
--})
--hl.window_rule({
--	match = { class = "^(code)$" },
--	workspace = "11",
--	center = true,
--})
