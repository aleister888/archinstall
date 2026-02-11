-- Establecer el tipo de los archivos hjson como json
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.hjson",
	command = "set filetype=json",
})

-- Syntax Highlighting para todos los archivos que se llamen sudoers
vim.filetype.add({
	filename = {
		sudoers = "sudoers",
	},
})
