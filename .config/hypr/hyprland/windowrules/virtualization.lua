hl.window_rule({
	match = { class = "^(virt-manager)$" },
	workspace = "7",
})

hl.window_rule({
	match = { title = "^(Gestor de Máquinas Virtuales)$" },
	tag = "+1/2",
})

hl.window_rule({
	match = { class = "^(remote-viewer)$" },
	workspace = "7",
})

hl.window_rule({
	match = {
		class = "^(remote-viewer)$",
		initial_title = "^(spice.*)$",
	},
	tile = true,
})

hl.window_rule({
	match = {
		class = "^(remote-viewer)$",
		title = "^(Preferencias)$",
	},
	tag = "+1/3",
})

hl.window_rule({
	match = {
		class = "^(remote-viewer)$",
		title = "^(Save screenshot)$",
	},
	tag = "+1/3",
})

hl.window_rule({
	match = {
		class = "^(remote-viewer)$",
		title = "^(Detalles de Huésped)$",
	},
	tag = "+1/3",
})

hl.window_rule({
	match = {
		class = "^(looking-glass-client)$",
	},
	workspace = "7",
})

hl.window_rule({
	match = {
		class = "^(qemu-system-x86_64)$",
	},
	workspace = "7",
})
