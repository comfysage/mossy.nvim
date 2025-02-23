local config = require("thistle.config")

local log = {}

local stack = {}

local function getdebuginfo()
	local i = 2
	local info = debug.getinfo(i, "nSf")
	local nextinfo = debug.getinfo(i + 1, "n")
	while nextinfo and info.name == nil do
		info = nextinfo
		i = i + 1
		nextinfo = debug.getinfo(i + 1, "n")
	end
	return info
end

---@param msg string
---@param level integer
function log.notify(msg, level)
	local debuginfo = getdebuginfo()
	local info = string.format(
		"%s %s at %s",
		#debuginfo.namewhat > 0 and debuginfo.namewhat or "chunk",
		debuginfo.name or "main",
		debuginfo.short_src or "main loop"
	)
	stack[#stack + 1] = { level, info, msg }
	msg = string.format("in %s:\n\t%s", info, msg)
	if level >= vim.log.levels.ERROR then
		return error(msg)
	end
	if level < config.get().log_level then
		return
	end
	vim.notify_once(msg, level)
	return level
end

---@param msg string
function log.trace(msg)
	return log.notify(msg, vim.log.levels.TRACE)
end

---@param msg string
function log.debug(msg)
	return log.notify(msg, vim.log.levels.DEBUG)
end

---@param msg string
function log.info(msg)
	return log.notify(msg, vim.log.levels.INFO)
end

---@param msg string
function log.warn(msg)
	return log.notify(msg, vim.log.levels.WARN)
end

---@param msg string
function log.error(msg)
	return log.notify(msg, vim.log.levels.ERROR)
end

---@param level? integer
---@param limit? integer
function log.get(level, limit)
	local it = vim.iter(ipairs(stack)):filter(function(_, item)
		if item[1] < level then
			return false
		end
	end)
	if limit then
		it = it:take(limit)
	end
	return it:totable()
end

return log
