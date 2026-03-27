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

				numbers = function(opts)
					return string.format("%s", opts.ordinal)
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
	vim.keymap.set("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>", { silent = true }),
	vim.keymap.set("n", "<leader>0", ":BufferLineGoToBuffer 10<CR>", { silent = true }),
}
