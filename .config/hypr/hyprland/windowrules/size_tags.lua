hl.window_rule({
	float = true,
	center = true,
	size = { "(monitor_w*0.33)", "(monitor_h*0.33)" },
	match = { tag = "1/3" },
})

hl.window_rule({
	float = true,
	center = true,
	size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
	match = { tag = "1/2" },
})

hl.window_rule({
	float = true,
	center = true,
	size = { "(monitor_w*0.66)", "(monitor_h*0.66)" },
	match = { tag = "2/3" },
})

hl.window_rule({
	float = true,
	center = true,
	size = { "(monitor_w*0.75)", "(monitor_h*0.75)" },
	match = { tag = "3/4" },
})

hl.window_rule({
	float = true,
	center = true,
	size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
	match = { tag = "center" },
})
