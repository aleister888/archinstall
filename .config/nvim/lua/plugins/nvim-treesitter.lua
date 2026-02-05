return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			require("nvim-treesitter").install({
				"arduino",
				"bash",
				"c",
				"cpp",
				"css",
				"csv",
				"diff",
				"gitattributes",
				"gitcommit",
				"hyprlang",
				"json",
				"kotlin",
				"latex",
				"lua",
				"markdown",
				"prolog",
				"ruby",
				"scss",
				"xml",
				"yuck",
			}),
		})
	end,
}
