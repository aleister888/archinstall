return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		-- Configuración básica de telescope
		telescope.setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			},
		})

		-- Cargar la extensión ui-select
		telescope.load_extension("ui-select")

		-- Búsqueda de archivos con fzf (nombre)
		vim.keymap.set("n", "<leader>T", builtin.find_files, { noremap = true, silent = true, desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true, desc = "Live grep" })
	end,
}
