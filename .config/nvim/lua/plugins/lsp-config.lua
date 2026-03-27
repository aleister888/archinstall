local servers = {
	"bashls",
	"clangd",
	"cssls",
	"jdtls",
	"kotlin_language_server",
	"markdown_oxide",
	"pylsp",
	"rust_analyzer",
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

			-- Ir al diagnóstico anterior
			keymap.set("n", "<leader>z", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end)
			-- Ir al siguiente diagnóstico
			keymap.set("n", "<leader>x", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end)
			-- Mostrar diagnóstico en una ventana flotante
			keymap.set("n", "<leader>c", vim.diagnostic.open_float)
			-- Acciones posibles
			vim.keymap.set("n", "<leader>C", vim.lsp.buf.code_action, {})
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
			local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
			local blink_status_ok, blink = pcall(require, "blink.cmp")
			if blink_status_ok then
				lsp_capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, blink.get_lsp_capabilities())
			end

			-- Configuramos todos los lsp con las capacidades basicas
			vim.lsp.config("*", {
				capabilities = lsp_capabilities,
			})

			-- Lista de códigos de Rust que quieres ocultar
			local filtered_codes = {
				"E0061",
			}

			-- Intercepta y filtra diagnostics antes de mostrarlos
			vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
				if not result then
					return
				end
				local filtered = vim.tbl_filter(function(d)
					-- d.code puede ser string o number
					local code = tostring(d.code or "")
					return not vim.tbl_contains(filtered_codes, code)
				end, result.diagnostics)
				result.diagnostics = filtered
				vim.lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
			end

			-- Ejecutar bashls en archivos zsh
			vim.lsp.config("bashls", {
				filetypes = { "bash", "sh", "zsh" },
			})

			require("mason-tool-installer").setup({
				ensure_installed = { "java-debug-adapter", "java-test" },
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {}, -- required, even if empty
	},
}
