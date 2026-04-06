return {
	"hat0uma/csvview.nvim",
	ft = { "csv" },
	opts = {
		parser = { comments = { "#", "//" } },
		ft = { "csv" },
		keymaps = {
			-- Text objects for selecting fields
			jump_next_field_end = { "<Tab>", mode = { "i", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "i", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
	config = function(_, opts)
		require("csvview").setup(opts)
		-- Cargar los atajos solo para el tipo de archivo 'csv'
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "csv",
			callback = function()
				vim.keymap.set("n", "<localleader>f", function()
					vim.cmd("CsvViewToggle display_mode=border")
				end, { silent = true, buffer = true })
			end,
		})
	end,
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
