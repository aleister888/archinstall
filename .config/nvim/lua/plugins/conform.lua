return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>a",
			function()
				require("conform").format({ async = false })
			end,
			mode = "",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			java = { "astyle" },
			sh = { "shfmt" },
			zsh = { "shfmt" },
			tex = { "latexindent" },
			scss = { "prettier" },
			css = { "prettier" },
			json = { "prettier" },
			hjson = { "prettier_json" },
			jsonc = { "prettier" },
			xml = { "xmllint" },
		},
		format_on_save = { timeout_ms = 5000 },
		formatters = {
			prettier_json = {
				command = "prettier",
				-- Desactivar el wrap para archivos json
				args = { "--parser", "json", "--print-width", "0" },
				stdin = true,
			},
			prettier = {
				prepend_args = { "--print-width", "80" },
			},
			astyle = {
				prepend_args = { "--style=java", "--indent=tab=8", "--squeeze-lines=1", "-n" },
			},
			latexindent = {
				prepend_args = {
					"--curft=/tmp",
					"-",
				},
			},
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
