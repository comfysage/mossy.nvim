local config = require("thistle.config")
local ft = require("thistle.ft")

local M = {}

function M.setup(cfg)
	cfg = cfg or {}
	config.set(config.override(cfg))

	vim.api.nvim_create_autocmd("BufAdd", {
		group = vim.api.nvim_create_augroup("thistle.format:check", { clear = true }),
		callback = function(ev)
			require("thistle").init(ev.buf)
		end,
	})
end

---@param buf? integer
function M.init(buf)
	buf = buf or 0

	local filetype = vim.filetype.match({ buf = buf })
	if not filetype then
		return
	end
	local cfg = ft(filetype):fold()[filetype]
	if not cfg or not cfg.format_on_save then
		return
	end

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup(("thistle.format[%d]"):format(buf), { clear = true }),
		callback = function(ev)
			require("thistle").format(ev.buf)
		end,
		buffer = buf,
	})
end

---@param buf? integer
function M.format(buf)
	buf = buf or 0
	return require("thistle.fmt").fmt(buf)
end

return M
