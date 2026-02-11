local opt = vim.opt

-- Borrar automáticamente los espacios sobrantes al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function()
		local currPos = vim.fn.getpos(".")
		vim.cmd("%s/\\s\\+$//e") -- Eliminar espacios al final de las líneas
		vim.cmd("%s/\\n\\+\\%$//e") -- Eliminar saltos de línea al final del archivo
		vim.fn.cursor(currPos[2], currPos[3]) -- Restaurar la posición del cursor
	end,
})

opt.winborder = "rounded"
opt.title = true
opt.encoding = "utf-8"
opt.scrolloff = 5
opt.wrap = true
-- Opciones del cursor
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.colorcolumn = "80"
-- Visualizar caracteres invisibles
opt.list = true
opt.listchars = { tab = "| ", trail = "·", lead = "·", precedes = "<", extends = ">" }
-- Ajustes de búsqueda
opt.ignorecase = true
opt.incsearch = true

-- Permitir el acceso global al porta-papeles
opt.clipboard = "unnamedplus"

opt.mouse = "a" -- Permitir el uso del mouse en todos los modos
opt.tags = "/dev/null" -- Desactivar ctags
opt.hidden = true -- Cambiar de buffer sin guardar los cambios
opt.autochdir = true -- Cambiar el directorio de trabajo al del archivo
opt.ttimeoutlen = 0 -- Tiempo de espera entre teclas
opt.wildmode = "longest,list,full" -- Navegación y autocompletado de comandos
opt.pumheight = 10 -- Altura máxima del menú de autocompletado
opt.laststatus = 3 -- Una sola barra de estado
