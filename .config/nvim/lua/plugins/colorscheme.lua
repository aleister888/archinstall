local M = {}
M.colors = {
	bg = "#30363D",
	fg = "#adbac7",
	alt_fg = "#636e7b",
	yellow = "#daaa3f",
	cyan = "#56d4dd",
	darkblue = "#539bf5",
	green = "#6bc46d",
	violet = "#dcbdfb",
	magenta = "#b083f0",
	blue = "#6cb6ff",
	red = "#ff938a",
}

package.loaded["colorscheme"] = M

return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("github-theme").setup({
			-- ...
		})

		vim.cmd("colorscheme github_dark_dimmed")
	end,
}
