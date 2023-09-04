local autocmd = vim.api.nvim_create_autocmd
local dart_tools_group = vim.api.nvim_create_augroup("DartTools", { clear = true })

autocmd({ "BufWritePost" }, {
	group = dart_tools_group,
	pattern = { "*.dart" },
	callback = function()
		os.execute("pgrep -f -o '[f]lutter_tool.*run' | xargs kill -s USR1")
	end,
})
