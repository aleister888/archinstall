-- Juegos
hl.window_rule({
	match = { class = "^(steam_app_[0-9]+)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = { class = "^(Project Zomboid)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = { class = "^(PlagueIncEvolved.x86_64)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = {
		class = "^(Terraria.bin.x86_64)$",
	},
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = { class = "^(gamescope)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = { class = "^(Xephyr)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "14",
})
hl.window_rule({
	match = { title = "^(OpenRA)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "9",
})
hl.window_rule({
	match = { class = "^(Ryujinx)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "9",
})
hl.window_rule({
	match = { class = "^(TJPS_Vulkan)$" },
	idle_inhibit = "focus",
	center = true,
	workspace = "9",
})
hl.window_rule({
	match = { title = "^(DOOM Eternal Launcher.*)$" },
	workspace = "15",
	float = true,
})
hl.window_rule({
	match = { title = "^(Minecraft.*)$" },
	tile = true,
	idle_inhibit = "focus",
	nearest_neighbor = true,
	workspace = "15",
})
hl.window_rule({
	match = { title = "^(Minecraft .*)$" },
	tile = true,
	idle_inhibit = "focus",
	nearest_neighbor = true,
	workspace = "15",
})
hl.window_rule({
	match = { title = "^(Minecraft* .*)$" },
	tile = true,
	idle_inhibit = "focus",
	nearest_neighbor = true,
	workspace = "15",
})
hl.window_rule({
	match = { class = "^(heroic)$" },
	workspace = "10",
})

-- Steam
hl.window_rule({
	match = { class = "^(steam)$" },
	workspace = "10",
})
hl.window_rule({
	match = { title = "^(Steam)$" },
	workspace = "10",
})
hl.window_rule({
	match = { class = "^(streaming_client)$" },
	workspace = "10",
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(Steam Big Picture Mode)$" },
	workspace = "10",
	idle_inhibit = "focus",
})
hl.window_rule({
	match = { title = "^(notificationtoasts.*desktop)" },
	workspace = "10",
})
hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Friends List)$",
	},
	tag = "+center",
})
hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Launching...)$",
	},
	tag = "+center",
})
hl.window_rule({
	match = {
		title = "^(Steam)$",
		class = "^()$",
	},
	tag = "+center",
})
hl.window_rule({
	match = {
		class = "^(steam)$",
		title = "^(Sign in to Steam)$",
	},
	center = true,
})

-- PrismLauncher
hl.window_rule({
	name = "prismlauncher_general",
	match = { class = "^(org.prismlauncher.PrismLauncher)$" },
	float = true,
	center = true,
	workspace = "special:scratch",
	no_initial_focus = true,
	size = { 450, 400 },
})
hl.window_rule({
	name = "prismlauncher_waiting",
	match = {
		class = "^(org.prismlauncher.PrismLauncher)$",
		title = "^(Por favor espera... — Prism Launcher .*)$",
	},
	border_size = 0,
	no_initial_focus = true,
	no_shadow = true,
	size = { "(monitor_w*0.35)", "(monitor_h*0.2)" },
})
hl.window_rule({
	name = "prismlauncher_main",
	match = {
		class = "^(org.prismlauncher.PrismLauncher)$",
		title = "^(Prism Launcher (.[0-9])*)$",
	},
	size = { "(monitor_w*0.4)", "(monitor_h*0.5)" },
})

-- Misc
hl.window_rule({
	match = { title = "^(NBTExplorer)$" },
	workspace = "9",
	tile = true,
	rounding = 0,
})
