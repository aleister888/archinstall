local opt = vim.opt

opt.conceallevel = 2
opt.winborder = "rounded"
-- Título de la ventana: Título del archivo
opt.title = true
-- Codificación de caracteres: UTF-8
opt.encoding = "utf-8"
-- Permitir el uso del mouse en todos los modos
opt.mouse = "a"
-- Desactivar ctags
opt.tags = "/dev/null"
-- Cambiar de buffer sin guardar los cambios
opt.hidden = true
-- Cambiar el directorio de trabajo al del archivo
opt.autochdir = true
-- Tiempo de espera entre teclas
opt.ttimeoutlen = 0
-- Navegación y autocompletado de comandos
opt.wildmode = "longest,list,full"
-- Altura máxima del menú de autocompletado
opt.pumheight = 10
-- Añadir márgenes en los extremos de la ventana
opt.scrolloff = 5
-- Desactiva el ajuste de línea
opt.wrap = true
-- Una sola barra de estado para todas las ventanas
opt.laststatus = 3
-- Opciones del cursor
opt.number = true
opt.relativenumber = true
opt.cursorline = true
-- Ajustes de búsqueda
opt.ignorecase = true
opt.incsearch = true
-- Líneas de separación vertical y caracteres invisibles
opt.list = true
opt.listchars = { tab = "| ", trail = "·", lead = "·", precedes = "<", extends = ">" }
-- Marcar la columna 80
opt.colorcolumn = "80"

-- Permitir el acceso global al porta-papeles
opt.clipboard = "unnamedplus"

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
