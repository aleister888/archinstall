-- Configuración por defecto para todos los tipos de archivo
local default_config = {
	smartindent = false,
	cindent = false,
	expandtab = false,
	copyindent = true,
	preserveindent = true,
	tabstop = 2,
	shiftwidth = 2,
	conceallevel = 2,
}

-- Configuraciones específicas por tipo de archivo
local filetype_configs = {
	["*css"] = { expandtab = true },
	conf = { tabstop = 8, shiftwidth = 8 },
	css = { expandtab = true },
	fstab = { tabstop = 8, shiftwidth = 8 },
	hyprlang = { tabstop = 4, shiftwidth = 4 },
	json = { smartindent = true, expandtab = true, conceallevel = 2 },
	kotlin = { expandtab = true, tabstop = 4, shiftwidth = 4 },
	markdown = { expandtab = true, conceallevel = 0 },
	python = { expandtab = true, tabstop = 4, shiftwidth = 4 },
	rasi = { expandtab = true },
	rust = { expandtab = true, tabstop = 4, shiftwidth = 4 },
	sh = { tabstop = 4, shiftwidth = 4 },
	sql = { expandtab = true, tabstop = 4, shiftwidth = 4 },
	tex = { smartindent = true, expandtab = true, tabstop = 2, shiftwidth = 2, conceallevel = 0 },
	toml = { expandtab = true, tabstop = 4, shiftwidth = 4 },
	xml = { expandtab = true },
}

-- Función para aplicar configuración
local function apply_config(config)
	local opt = vim.opt_local
	for key, value in pairs(config) do
		opt[key] = value
	end
end

-- Aplicamos la configuración por defecto
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function(args)
		apply_config(default_config)
	end,
})

-- Aplicamos las configuraciones específicas
for pattern, config in pairs(filetype_configs) do
	local merged_config = vim.tbl_extend("force", {}, default_config, config)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = pattern,
		callback = function()
			apply_config(merged_config)
		end,
	})
end
