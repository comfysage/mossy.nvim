local log = {}

log.debugopt = vim.o.debug

local function getdebuginfo()
  local i = 3
  local info = debug.getinfo(i, "nSf")
  local nextinfo = debug.getinfo(i + 1, "n")
  while nextinfo and info.name == nil do
    info = nextinfo
    i = i + 1
    nextinfo = debug.getinfo(i + 1, "n")
  end
  return info
end

---@class mossy.logmsg
---@field msg string
---@field level integer
---@field info string
local LogMsg = {}

---@param msg string
---@param level? integer
---@param debuginfo? any
function LogMsg:new(msg, level, debuginfo)
  debuginfo = debuginfo or getdebuginfo()
  local info = string.format(
    "%s %s at %s",
    #debuginfo.namewhat > 0 and debuginfo.namewhat or "chunk",
    debuginfo.name or "main",
    debuginfo.short_src or "main loop"
  )
  msg = string.format("in %s:\n\t%s", info, msg)
  return setmetatable({
    msg = msg,
    level = level or vim.log.levels.INFO,
    info = info,
  }, LogMsg)
end

log.stack = {}

---@param item mossy.logmsg
---@return mossy.logmsg?
function log.notify(item)
  log.stack[#log.stack + 1] = item
  if log.debugopt == "" and item.level < vim.log.levels.INFO then
    return
  end
  if log.debugopt == "throw" and item.level >= vim.log.levels.ERROR then
    error(log.msg, item.level)
    return
  end
  if vim.in_fast_event() then
    require("nio").scheduler()
  end
  vim.notify(item.msg, item.level)
  return item
end

---@param msg string
function log.trace(msg)
  return log.notify(LogMsg:new(msg, vim.log.levels.TRACE, getdebuginfo()))
end

---@param msg string
function log.debug(msg)
  return log.notify(LogMsg:new(msg, vim.log.levels.DEBUG, getdebuginfo()))
end

---@param msg string
function log.info(msg)
  return log.notify(LogMsg:new(msg, vim.log.levels.INFO, getdebuginfo()))
end

---@param msg string
function log.warn(msg)
  return log.notify(LogMsg:new(msg, vim.log.levels.WARN, getdebuginfo()))
end

---@param msg string
function log.error(msg)
  return log.notify(LogMsg:new(msg, vim.log.levels.ERROR, getdebuginfo()))
end

return log
