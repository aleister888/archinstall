return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"onsails/lspkind.nvim",
		},
		version = "1.*",
		config = function()
			local lspkind = require("lspkind")

			lspkind.init({
				mode = "symbol_text",
				preset = "codicons",
				symbol_map = {
					Text = "󰉿",
					Method = "󰆧",
					Function = "󰊕",
					Constructor = "",
					Field = "󰜢",
					Variable = "󰀫",
					Class = "󰠱",
					Interface = "",
					Module = "",
					Property = "󰜢",
					Unit = "󰑭",
					Value = "󰎠",
					Enum = "",
					Keyword = "󰌋",
					Snippet = "",
					Color = "󰏘",
					File = "󰈙",
					Reference = "󰈇",
					Folder = "󰉋",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "󰙅",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "",
				},
			})

			require("blink.cmp").setup({
				completion = {
					menu = {
						draw = {
							components = {
								kind_icon = {
									text = function(item)
										local kind = lspkind.symbol_map[item.kind] or ""
										return kind .. ""
									end,
								},
							},
						},
					},
					documentation = { auto_show = true },
				},
				sources = {
					default = { "lsp", "path", "buffer" },
					providers = {},
				},
				keymap = {
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<S-Tab>"] = { "accept", "fallback" },
				},
			})
		end,
	},
}
