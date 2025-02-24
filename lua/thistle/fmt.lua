local log = require("thistle.log")
local utils = require("thistle.utils")
local ft = require("thistle.ft")

local M = {}

---@param buf integer
---@param range? thistle.utils.range
---@param formatter thistle.fmt.config
---@return true|any
local function do_pure_fmt(buf, range, formatter)
	local srow, erow = 0, -1
	if range then
		srow = range.rstart[1] - 1
		erow = range.rend[1]
	end
	local prev_lines = vim.api.nvim_buf_get_lines(buf, srow, erow, false)
	local prev_lines_str = table.concat(prev_lines, "\n")
	local errno = nil
	local changedtick = -1
	-- defer initialization, since BufWritePre would trigger a tick change
	vim.schedule(function()
		changedtick = vim.api.nvim_buf_get_changedtick(buf)
	end)

	-- check if we are in a valid state
	vim.schedule(function()
		if vim.api.nvim_buf_get_changedtick(buf) ~= changedtick then
			errno = { reason = "buffer changed" }
		end
	end)

	if errno then
		return errno
	end

	local new_lines = nil
	if formatter.fn then
		new_lines = formatter.fn({ buf = buf, range = range })
	else
		local result =
			utils.spawn(utils.get_cmd(formatter, { buf = buf, range = range }), nil, formatter, prev_lines_str)
		if type(result) == "table" then
			-- indicates error
			errno = result
			errno.reason = formatter.cmd .. " exited with errors"
			errno.cmd = formatter.cmd
			return errno
		else
			---@diagnostic disable-next-line: return-type-mismatch
			new_lines = result
		end
	end

	if errno then
		if errno.cmd and errno.code and errno.stderr then
			return ("%s exited with code %d\n%s"):format(errno.cmd, errno.code, errno.stderr)
		elseif errno.reason then
			return errno.reason
		end
		return errno
	end

	vim.schedule(function()
		-- check buffer one last time
		if vim.api.nvim_buf_get_changedtick(buf) ~= changedtick then
			errno = "buffer changed during formatting"
			return
		end
		if not vim.api.nvim_buf_is_valid(buf) then
			errno = "buffer no longer valid"
			return
		end
		if not new_lines then
			errno = "no newlines returned"
			return
		end
		utils.update_buffer(buf, prev_lines, new_lines, srow, erow)
	end)

	if errno then
		return errno
	end

	return true
end

---@param buf integer
---@param formatter thistle.fmt.config
---@return true|any
local function do_impure_fmt(buf, formatter)
	local errno = nil

	vim.system(utils.get_cmd(formatter, { buf = buf }), {
		text = true,
		env = formatter.env or {},
	}, function(result)
		if result.code ~= 0 and #result.stderr > 0 then
			errno = result
			---@diagnostic disable-next-line: inject-field
			errno.cmd = formatter.cmd
		end
		vim.schedule(function()
			vim.api.nvim_buf_call(buf, function()
				local views = utils.save_views(buf)
				vim.api.nvim_command("silent! edit!")
				utils.restore_views(views)
			end)
		end)
	end)

	return errno
end

---@param buf integer
---@param range? thistle.utils.range
---@param formatter thistle.fmt.config
---@return true|any
local function do_fmt(buf, range, formatter)
	if range and not formatter.stdin then
		return log.debug("cannot format range with this formatter: " .. formatter.cmd)
	end

	if formatter.cond and not formatter.cond({ buf = buf, range = range }) then
		return log.debug("condition returned false for formatter: " .. formatter.cmd)
	end

	local result = nil
	if formatter.stdin then
		result = do_pure_fmt(buf, range, formatter)
	else
		result = do_impure_fmt(buf, formatter)
	end

	if result then
		return log.error(result)
	end

	log.debug("finished formatting")

	return true
end

---@param buf integer
function M.fmt(buf)
	local filetype = vim.filetype.match({ buf = buf })
	if not filetype then
		return
	end
	local cfg = ft(filetype):fold()[filetype]
	if not cfg.formatters or vim.tbl_isempty(cfg.formatters) then
		return log.error("no formatters configured")
	end

	local range = nil
	local mode = vim.api.nvim_get_mode().mode
	if mode == "V" or mode == "v" then
		range = utils.range_from_selection(buf, mode == "V")
	end

	coroutine.resume(coroutine.create(function()
		vim.iter(ipairs(cfg.formatters)):find(function(_, formatter)
			return do_fmt(buf, range, formatter) == true
		end)
	end))
end

return M
