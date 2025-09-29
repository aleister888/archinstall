local servers = {
	"bashls",
	"cssls",
	"jdtls",
	"lua_ls",
	"markdown_oxide",
	"texlab",
}

-- Configure diagnostic display with custom signs
vim.diagnostic.config({
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = true, -- Show source in diagnostic popup window
		header = "",
		prefix = "",
	},
	virtual_text = false,
	virtual_lines = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Enable inlay hints
vim.lsp.inlay_hint.enable(true)

local keymap = vim.keymap
return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function()
			local opts = { silent = true }

			vim.keymap.set("n", "<leader>A", vim.lsp.buf.code_action, {})
			-- Mostrar diagnóstico en una ventana flotante
			keymap.set("n", "<leader>i", vim.diagnostic.open_float)
			-- Ir al diagnóstico anterior
			keymap.set("n", "<leader>o", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end)
			-- Ir al siguiente diagnóstico
			keymap.set("n", "<leader>p", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end)
			return {
				ensure_installed = servers,
				automatic_enable = true,
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			require("lspconfig")
			local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
			local blink_status_ok, blink = pcall(require, "blink.cmp")
			if blink_status_ok then
				lsp_capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, blink.get_lsp_capabilities())
			end
			vim.lsp.config("*", {
				capabilities = lsp_capabilities,
			})
			require("mason-tool-installer").setup({
				ensure_installed = { "java-debug-adapter", "java-test" },
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
}
