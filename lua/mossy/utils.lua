local log = require("mossy.log")

local utils = {}

---@param method mossy.method
---@return boolean
function utils.is_valid_method(method)
	return (method == "diagnostics" or method == "formatting")
end

---@param cfg mossy.source|string
---@return mossy.source|any
function utils.parsecfg(cfg)
	if type(cfg) == "string" then
		local source = require("mossy.builtins").get(cfg)
		if not source then
			return log.error(string.format("could not find builtin: '%s'", cfg))
		end

		return source
	end
	if not cfg.name then
		return log.error("source has no name")
	end
	if not cfg.method or not utils.is_valid_method(cfg.method) then
		return log.error(("(%s) method of source is not valid, got '%s'"):format(cfg.name, cfg.method))
	end
	if not (cfg.cmd or cfg.fn) then
		return log.error(string.format("(%s) source needs a `cmd` or `fn` field but got none", cfg.name))
	end
	if cfg.cmd then
		if not cfg.args then
			cfg.args = {}
		end
		if cfg.stdin == nil then
			cfg.stdin = true
		end
	else
		-- source is a function
		if cfg.args or cfg.stdin then
			return log.error(string.format("(%s) source is a function but has command fields", cfg.name))
		end
	end
	return cfg
end

---@alias mossy.utils.range { ["rstart"|'rend']: { [1]: integer, [2]: integer } } uses (1, 0) indexing

---@param buf integer
---@param lineselect boolean
---@return mossy.utils.range
function utils.range_from_selection(buf, lineselect)
	local rstart = vim.fn.getpos("v")
	local rend = vim.fn.getpos(".")
	local start_row = rstart[2]
	local start_col = rstart[3]
	local end_row = rend[2]
	local end_col = rend[3]
	if start_row == end_row and end_col < start_col then
		end_col, start_col = start_col, end_col
	elseif end_row < start_row then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end
	if lineselect then
		start_col = 1
		local lines = vim.api.nvim_buf_get_lines(buf, end_row - 1, end_row, true)
		end_col = #lines[1]
	end
	return {
		rstart = { start_row, start_col - 1 },
		rend = { end_row, end_col - 1 },
	}
end

---@param buf integer
---@return { [integer]: table }
function utils.save_views(buf)
	local views = {}
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
	end
	return views
end

---@param views { [integer]: table }
function utils.restore_views(views)
	for win, view in pairs(views) do
		vim.api.nvim_win_call(win, function()
			vim.fn.winrestview(view)
		end)
	end
end

---@param buf integer
---@param prev_lines string[]
---@param new_lines string
---@param srow integer
---@param erow integer
function utils.update_buffer(buf, prev_lines, new_lines, srow, erow)
	if not new_lines or #new_lines == 0 then
		return
	end

	local views = utils.save_views(buf)
	-- \r\n for windows compatibility
	---@diagnostic disable-next-line: cast-local-type
	new_lines = vim.split(new_lines, "\r?\n")
	if new_lines[#new_lines] == "" then
		new_lines[#new_lines] = nil
	end

	if not vim.deep_equal(new_lines, prev_lines) then
		---@type number?
		local old_indent
		if vim.api.nvim_get_mode().mode == "V" then
			old_indent = vim.fn.indent(srow + 1)
		end
		vim.api.nvim_buf_set_lines(buf, srow, erow, false, new_lines)
		if old_indent then
			vim.cmd(("silent %d,%dleft"):format(srow + 1, erow))
		end
		utils.restore_views(views)
	end
end

---@param config mossy.source.formatting
---@param params mossy.formatting.params
function utils.get_cmd(config, params)
	local cmd = { config.cmd }
	if not config.args then
		return cmd
	end
	local args = config.args or {}
	if type(args) == "function" then
		args = args(params)
	end
	return vim.list_extend(cmd, args)
end

---@param cmd string[]
---@param cwd? string
---@param config mossy.source.formatting
---@param lines string|string[]
---@return table | string
function utils.spawn(cmd, cwd, config, lines)
	local co = assert(coroutine.running())
	local handle = vim.system(cmd, {
		stdin = true,
		cwd = cwd,
		env = config.env,
	}, function(result)
		if result.code ~= 0 and #result.stderr > 0 then
			-- error
			coroutine.resume(co, result)
		else
			coroutine.resume(co, result.stdout)
		end
	end)
	-- write to stdin and close it
	handle:write(lines)
	handle:write(nil)
	return coroutine.yield()
end

return utils
