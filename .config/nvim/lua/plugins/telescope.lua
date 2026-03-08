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

		-- Function to get Git root
		local function git_root()
			local handle = io.popen("git rev-parse --show-toplevel 2> /dev/null")
			local result = handle:read("*a")
			handle:close()
			result = result:gsub("\n", "")
			if result == "" then
				return vim.loop.cwd() -- fallback to current working directory
			else
				return result
			end
		end

		-- Cargar la extensión ui-select
		telescope.load_extension("ui-select")

		-- Búsqueda de archivos con fzf (nombre)
		vim.keymap.set("n", "<leader>t", function()
			builtin.find_files({ cwd = git_root() })
		end, { noremap = true, silent = true })

		vim.keymap.set("n", "<leader>T", function()
			builtin.live_grep({ cwd = git_root() })
		end, { noremap = true, silent = true })
	end,
}
