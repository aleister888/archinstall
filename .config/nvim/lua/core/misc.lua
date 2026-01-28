vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.hjson",
	command = "set filetype=json",
})
