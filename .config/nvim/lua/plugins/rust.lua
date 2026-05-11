return {
	"mrcjkb/rustaceanvim",
	version = "^4",
	lazy = false,
	config = function()
		vim.g.rust_recommended_style = false
		vim.g.rustaceanvim = {
			server = {
				on_attach = function(_, bufnr)
					vim.lsp.inlay_hint.enable(true, { bufnr })
				end,
			},
			tools = {
				enable_clippy = true,
			},
		}
	end,
}
