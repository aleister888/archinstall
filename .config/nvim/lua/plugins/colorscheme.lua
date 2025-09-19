local M = {}

M.colors = {
	bg = "#282828",
	fg = "#a89984",
	yellow = "#d79921",
	cyan = "#689d6a",
	darkblue = "#076678",
	green = "#98971a",
	orange = "#fe8019",
	violet = "#b16286",
	magenta = "#8f3f71",
	blue = "#458588",
	red = "#cc241d",
}

function SetColorscheme()
	vim.cmd.colorscheme("gruvbox")
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = M.colors.bg, fg = M.colors.fg })
	-- Cambiar el color de los números de línea
	vim.api.nvim_set_hl(0, "LineNr", { bg = M.colors.bg, fg = M.colors.fg })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = M.colors.bg, fg = M.colors.yellow, bold = true })
end

package.loaded["colorscheme"] = M

return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,
	config = function()
		require("gruvbox").setup({
			transparent_mode = true,
			inverse = false,
			contrast = "hard",
		})
		SetColorscheme()
	end,
}
