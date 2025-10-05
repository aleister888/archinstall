-- Configuración de indentación y tabulación

-- Configuración por defecto para todos los tipos de archivo
local default_config = {
	smartindent = false,
	cindent = false,
	expandtab = false,
	copyindent = true,
	preserveindent = true,
	tabstop = 4,
	shiftwidth = 4,
	conceallevel = 2,
}

-- Configuraciones específicas por tipo de archivo
local filetype_configs = {
	sql = {
		expandtab = true,
		tabstop = 4,
		shiftwidth = 4,
	},
	["json*"] = {
		smartindent = true,
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
		conceallevel = 0,
	},
	fstab = {
		tabstop = 8,
		shiftwidth = 8,
	},
	java = {}, -- Usa la configuración por defecto
	["*css"] = {
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
	},
	tex = {
		smartindent = true,
		expandtab = true,
		tabstop = 6,
		shiftwidth = 6,
	},
	xml = {
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
	},
	markdown = {
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
	},
	python = {
		expandtab = true,
		tabstop = 4,
		shiftwidth = 4,
	},
}

-- Función para aplicar configuración
local function apply_config(config)
	local opt = vim.opt_local
	for key, value in pairs(config) do
		opt[key] = value
	end
end

-- Configuración por defecto para todos los archivos
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		apply_config(default_config)
	end,
})

-- Configuraciones específicas por tipo de archivo
for pattern, config in pairs(filetype_configs) do
	-- Combinar con configuración por defecto
	local merged_config = vim.tbl_extend("force", {}, default_config, config)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = pattern,
		callback = function()
			apply_config(merged_config)
		end,
	})
end
