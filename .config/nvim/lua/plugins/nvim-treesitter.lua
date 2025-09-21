return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			highlight = {
				enable = true,
				-- Desactiva el highlighting para archivos grandes
				disable = function(lang, buf)
					-- Desactiva siempre para CSV
					if lang == "csv" then
						return true
					end

					-- Desactiva para archivos grandes
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			indent = { enable = true },
			auto_install = true,
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"css",
				"csv",
				"diff",
				"gitattributes",
				"gitcommit",
				"json",
				"latex",
				"lua",
				"markdown",
				"ruby",
				"scss",
				"xml",
				"yuck",
				"zathurarc",
			},
		})
	end,
}
