local function cargo_run()
	vim.cmd("!cargo build && cargo run")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<localleader>g", cargo_run, { buffer = 0, silent = true })
	end,
})

local function rustc_run()
	local file = vim.fn.expand("%:p")
	vim.cmd("!rustc " .. file .. " -o /tmp/rust.exe && clear && /tmp/rust.exe")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<localleader>G", rustc_run, { buffer = 0, silent = true })
	end,
})
