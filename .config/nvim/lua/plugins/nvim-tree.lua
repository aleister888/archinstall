return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.g.nvim_tree_respect_buf_cwd = 1
		require("nvim-tree").setup()

		-- Abrir/Cerrar nvim-tree
		vim.keymap.set("n", "<leader>tt", "<Cmd>NvimTreeToggle<CR>", { silent = true })
	end,
}
