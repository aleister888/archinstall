local function compile_run_rust()
	vim.cmd("!cargo build && cargo run")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<localleader>g", compile_run_rust, { buffer = 0, silent = true })
	end,
})
