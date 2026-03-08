return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },

	config = function()
		local bufferline = require("bufferline")

		bufferline.setup({
			options = {
				custom_filter = function(buf_number, buf_numbers)
					if vim.bo[buf_number].buftype == "terminal" or vim.bo[buf_number].buftype == "quickfix" then
						return false
					end

					return true
				end,

				offsets = {
					{
						filetype = "vimtex-toc",
					},
					{
						filetype = "qf",
					},
				},
			},
		})
	end,

	vim.keymap.set("n", "<leader>q", ":BufferLineCyclePrev<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>w", ":BufferLineCycleNext<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>Q", ":bdelete<CR>", { silent = true }),
}
