hl.window_rule({
	match = { class = "^(input-remapper-gtk)$" },
	tag = "+center",
})

hl.window_rule({
	match = { class = "^(gmetronome)$" },
	tag = "+center",
})

hl.window_rule({
	match = {
		class = "^(org.qbittorrent.qBittorrent)$",
		title = "^(.*magnet.*)$",
	},
	tag = "+center",
})

hl.window_rule({
	match = { class = "^(yad)$" },
	tag = "+center",
})

hl.window_rule({
	match = { title = "^(Citrahold PC.*)$" },
	tag = "+center",
})

hl.window_rule({
	match = { title = "^(Exportar imagen como .*)$" },
	tag = "+center",
})

hl.window_rule({
	match = { title = "^(Copy color to Clipboard)$" },
	tag = "+center",
})

hl.window_rule({
	match = {
		class = "^(org.qbittorrent.qBittorrent)$",
		title = "^(.*magnet.*)$",
	},
	tag = "+3/4",
})
