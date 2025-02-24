local config = require("mossy.config")
local ft = require("mossy.ft")

local M = {}

function M.setup(cfg)
	cfg = cfg or {}
	config.set(config.override(cfg))

	vim.api.nvim_create_autocmd("BufAdd", {
		group = vim.api.nvim_create_augroup("mossy.format:check", { clear = true }),
		callback = function(ev)
			require("mossy").init(ev.buf)
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
		group = vim.api.nvim_create_augroup(("mossy.format[%d]"):format(buf), { clear = true }),
		callback = function(ev)
			if config.get().enable then
				require("mossy").format(ev.buf)
			end
		end,
		buffer = buf,
	})
end

function M.disable()
	config.set(config.override({ enable = false }))
end

function M.enable()
	config.set(config.override({ enable = true }))
end

function M.toggle()
	if config.get().enable then
		M.disable()
	else
		M.enable()
	end
end

---@param buf? integer
function M.format(buf)
	buf = buf or 0
	return require("mossy.fmt").fmt(buf)
end

return M
