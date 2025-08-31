local nio = require("nio")

local config = require("mossy.config")
local log = require("mossy.log")
local utils = require("mossy.utils")

---@private
---@param formatter mossy.source.formatting
---@param arg1 string
---@param ... string
local function fmt_get_option(formatter, arg1, ...)
  local v = vim.tbl_get(formatter, arg1, ...)
  if formatter.config and v then
    return v
  end
  return vim.tbl_get(config.get().defaults.formatting, arg1, ...)
end

local format = {}

---@async
---@param buf integer
---@param range? mossy.utils.range
---@param formatter mossy.source.formatting
---@return string? err
local function do_pure_fmt(buf, range, formatter)
  local srow, erow = 0, -1
  if range then
    srow = range.rstart[1] - 1
    erow = range.rend[1]
  end
  local prev_lines = nio.api.nvim_buf_get_lines(buf, srow, erow, false)
  local prev_lines_str = table.concat(prev_lines, "\n")
  local new_lines = nil

  -- NOTE: defer initialization, since BufWritePre would trigger a tick change
  local changedtick = nil
  vim.schedule(function()
    changedtick = nio.api.nvim_buf_get_changedtick(buf)
  end)

  if formatter.fn then
    new_lines = formatter.fn({ buf = buf, range = range })
  else
    local props = utils.get_cmd(formatter, { buf = buf, range = range })
    if not props.cmd then
      return "formatter is missing a cmd field"
    end

    local handle, err = nio.process.run(props)

    -- write to stdin and close it
    handle.stdin.write(prev_lines_str)
    handle.stdin.close()

    new_lines = handle.stdout.read()

    if err then
      return ("%s exited with code %d\n%s"):format(formatter.cmd, handle.pid, err)
    end
  end

  if not new_lines then
    return "no newlines returned"
  end

  if formatter.on_output then
    new_lines = formatter.on_output(new_lines)
  end

  log.trace("received newlines")

  if not nio.api.nvim_buf_is_valid(buf) then
    return "buffer no longer valid"
  end

  -- check if we are in a valid state
  local newtick = nio.api.nvim_buf_get_changedtick(buf)
  if newtick ~= changedtick then
    return string.format("buffer changed: %d -> %d", changedtick, newtick)
  end

  local err = utils.update_buffer(buf, prev_lines, new_lines, srow, erow)
  if err then
    return "error while updating buffer: " .. err
  end
end

---@async
---@param buf integer
---@param formatter mossy.source.formatting
---@return string? err
local function do_impure_fmt(buf, formatter)
  local opts = utils.get_cmd(formatter, { buf = buf })
  if not opts.cmd then
    return "formatter is missing a cmd field"
  end

  local result, err = nio.process.run(opts)
  if err then
    return ("%s exited with code %d\n%s"):format(formatter.cmd, result.pid, err)
  end

  nio.api.nvim_buf_call(buf, function()
    local views = utils.save_views(buf)
    nio.api.nvim_command("silent! edit!")
    utils.restore_views(views)
  end)
end

---@param buf integer
---@param range? mossy.utils.range
---@param formatter mossy.source.formatting
---@param props mossy.format.props
---@return true|any
function format.request(buf, range, formatter, props)
  local format_on_save = fmt_get_option(formatter, "format_on_save")
  if format_on_save == nil then
    format_on_save = config.get().defaults.formatting.format_on_save
  end
  if props.autoformat and not format_on_save then
    return log.trace(("(%s) autoformat disabled"):format(formatter.name))
  end

  if range and not formatter.stdin then
    return log.warn(("(%s) formatter cannot format range"):format(formatter.name))
  end

  log.debug(("(%s) pending format"):format(formatter.name))

  nio.run(function()
    local err
    if formatter.stdin or formatter.fn then
      log.debug(("(%s) using pure formatting"):format(formatter.name))
      err = do_pure_fmt(buf, range, formatter)
    else
      log.debug(("(%s) using impure formatting"):format(formatter.name))
      err = do_impure_fmt(buf, formatter)
    end
    assert(not err, err)
  end, function(ok, err)
    if not ok and err then
      return log.error(string.format("(%s) error encountered while formatting:\n\t%s", formatter.name, err))
    end
  end)

  log.debug(("(%s) finished formatting"):format(formatter.name))
end

---@param buf integer
---@param props mossy.format.props
function format.try(buf, props)
  local formatters = require("mossy").get(buf)
  if #formatters == 0 then
    local use_lsp_fallback = require("mossy.config").get().defaults.formatting.use_lsp_fallback
    if use_lsp_fallback then
      local formatter = require("mossy.builtins").get("lsp")
      if not formatter then
        return log.debug("lsp builtin formatter could not be found")
      end
      formatters = { formatter }
    else
      return log.debug("no matching formatters configured")
    end
  end

  local range = nil
  local mode = vim.api.nvim_get_mode().mode
  if mode == "V" or mode == "v" then
    range = utils.range_from_selection(buf, mode == "V")
  end

  vim.iter(ipairs(formatters)):each(function(_, formatter)
    format.request(buf, range, formatter, props)
  end)
end

return format

