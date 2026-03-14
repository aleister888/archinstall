-- Borrar palabra atrás en insert mode con Ctrl+Backspace
vim.keymap.set("i", "<C-Backspace>", "<C-w>", { noremap = true, silent = true })

-- Limpiar búsqueda
vim.keymap.set("n", "<leader><BS>", ":noh<CR>", { silent = true })

-- Salir del modo terminal
vim.keymap.set("t", "<S-Esc>", [[<C-\><C-n>]], { noremap = true })

-- Split
vim.keymap.set("n", "<leader>v", "<C-w>v")
vim.keymap.set("n", "<leader>V", "<C-w>s")

-- Desplazarse por el texto
vim.keymap.set("n", "<ScrollWheelUp>", "k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-ScrollWheelUp>", "5k", { noremap = true, silent = true })
vim.keymap.set("n", "<ScrollWheelDown>", "j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-ScrollWheelDown>", "5j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Up>", "5k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Down>", "5j", { noremap = true, silent = true })

-- Moverse al final de la línea
vim.keymap.set("n", "=", "$", { noremap = true, silent = true })
vim.keymap.set("v", "=", "$h", { noremap = true, silent = true })

-- Encapsular texto seleccionado
vim.keymap.set("v", '"', 's"<C-r>""', { noremap = true, silent = true })
vim.keymap.set("v", "'", "s'<C-r>\"'", { noremap = true, silent = true })
vim.keymap.set("v", "`", 's`<C-r>"`', { noremap = true, silent = true })
vim.keymap.set("v", "$", 's$<C-r>"$', { noremap = true, silent = true })
vim.keymap.set("v", "(", 's(<C-r>")', { noremap = true, silent = true })
vim.keymap.set("v", ")", 's(<C-r>")', { noremap = true, silent = true })
vim.keymap.set("v", "{", 's{<C-r>"}', { noremap = true, silent = true })
vim.keymap.set("v", "}", 's{<C-r>"}', { noremap = true, silent = true })
vim.keymap.set("v", "[", 's[<C-r>"]', { noremap = true, silent = true })
vim.keymap.set("v", "]", 's[<C-r>"]', { noremap = true, silent = true })
vim.keymap.set("v", "¿", 's¿<C-r>"?', { noremap = true, silent = true })
vim.keymap.set("v", "?", 's¿<C-r>"?', { noremap = true, silent = true })

-- Cambiar entre ventanas
vim.keymap.set("n", "<leader>s", "<C-w>w", { noremap = true, silent = true })

-- Spawnear terminal
vim.keymap.set("n", "<localleader>t", function()
	local terminal = os.getenv("TERMINAL") or ""
	local terminal_opts = os.getenv("REGULAR_OPTS") or ""
	local cmd = string.format("%s %s &>/dev/null &", terminal, terminal_opts)
	vim.fn.execute("!" .. cmd)
end, { silent = true })

-- Abrir lf en el directorio actual
vim.keymap.set("n", "<localleader>e", function()
	local terminal = os.getenv("TERMINAL") or ""
	local terminal_opts = os.getenv("REGULAR_OPTS") or ""
	local terminal_exec = os.getenv("TERMEXEC") or ""
	local cmd = string.format("%s %s %s 'lf' &>/dev/null &", terminal, terminal_opts, terminal_exec)
	vim.fn.execute("!" .. cmd)
end, { silent = true })

-- Spawnear scratchpad
vim.keymap.set("n", "<localleader>T", function()
	local terminal = os.getenv("TERMINAL") or ""
	local termtitle = os.getenv("TERMTITLE") or ""
	local terminal_opts = os.getenv("SCRATCH_OPTS") or ""
	local cmd = string.format("%s %s %s scratchpad &>/dev/null &", terminal, terminal_opts, termtitle)
	vim.fn.execute("!" .. cmd)
end, { silent = true })

-- Abrir archivo HTML en el navegador Firefox
vim.api.nvim_create_autocmd("FileType", {
	pattern = "html",
	callback = function()
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<localleader>h",
			":!firefox --new-window %<CR>",
			{ noremap = true, silent = true }
		)
	end,
})
