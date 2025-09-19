return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		user_default_options = {
			names = false,
			names_opts = {
				lowercase = true,
				camelcase = true,
				uppercase = false,
				strip_digits = false,
			},
			names_custom = false,
			RGB = true,
			RGBA = true,
			RRGGBB = true,
			RRGGBBAA = true,
			AARRGGBB = true,
			rgb_fn = true,
			hsl_fn = true,
			css = true,
			css_fn = true,
			tailwind = true,
			tailwind_opts = {
				update_names = false,
			},
		},
	},
}
