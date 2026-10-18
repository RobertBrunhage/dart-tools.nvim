local signal = require("dart-tools.signal")

local autocmd = vim.api.nvim_create_autocmd
local dart_tools_group = vim.api.nvim_create_augroup("DartTools", { clear = true })

-- `flutter run` / `flutter attach` started from any terminal (global flags before the command are fine)
local FLUTTER_RUN_PATTERN = "flutter_tools\\.snapshot( -[^ ]+)* (run|attach)( |$)"

-- Sends `sig` to every running flutter app that is ready for it.
-- Apps that are still starting are skipped, signalling them would kill the process.
local function signal_flutter(sig)
	vim.system({ "pgrep", "-f", FLUTTER_RUN_PATTERN }, { text = true }, function(result)
		for pid in result.stdout:gmatch("%d+") do
			pid = tonumber(pid)
			if signal.catches(pid, vim.uv.constants[sig:upper()]) then
				vim.uv.kill(pid, sig)
			end
		end
	end)
end

autocmd({ "BufWritePost" }, {
	group = dart_tools_group,
	pattern = { "*.dart" },
	callback = function()
		signal_flutter("sigusr1")
	end,
})
