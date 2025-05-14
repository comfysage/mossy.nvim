local nio = require 'nio'

local log = require 'mossy.log'
local utils = require 'mossy.utils'
local ft = require 'mossy.filetype'
local config = require 'mossy.config'

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

---@param buf integer
---@param range? mossy.utils.range
---@param formatter mossy.source.formatting
---@return true|any
local function do_pure_fmt(buf, range, formatter)
  local srow, erow = 0, -1
  if range then
    srow = range.rstart[1] - 1
    erow = range.rend[1]
  end
  local prev_lines = vim.api.nvim_buf_get_lines(buf, srow, erow, false)
  local prev_lines_str = table.concat(prev_lines, '\n')
  local errno = nil
  local new_lines = nil

  local changedtick = -1
  -- NOTE: defer initialization, since BufWritePre would trigger a tick change
  vim.schedule(function()
    changedtick = vim.api.nvim_buf_get_changedtick(buf)
  end)

  local event = nio.control.event()

  if formatter.fn then
    nio.wrap(function(props)
      new_lines = formatter.fn(props)
      event.set()
    end, 1) { buf = buf, range = range }
  else
    nio.wrap(function(props)
      local result, err = utils.spawn(
        utils.get_cmd(formatter, props),
        nil,
        formatter,
        prev_lines_str
      )
      if err then
        -- indicates error
        errno = {}
        errno.code = result.pid
        errno.reason = formatter.cmd .. ' exited with errors'
        errno.cmd = formatter.cmd
        errno.stderr = err
        return errno
      end

      new_lines = result.stdout.read()
      if formatter.on_output then
        new_lines = formatter.on_output(new_lines)
      end
      event.set()
    end, 1) { buf = buf, range = range }
  end

  event.wait()

  if formatter.fn and not new_lines then
    return errno
  end

  if not new_lines then
    return 'no newlines returned'
  end

  vim.schedule(function()
    -- check if we are in a valid state
    if vim.api.nvim_buf_get_changedtick(buf) ~= changedtick then
      errno = 'buffer changed'
      return
    end

    if not vim.api.nvim_buf_is_valid(buf) then
      errno = 'buffer no longer valid'
      return
    end

    -- TODO: add `on_output` field to formatter

    errno = utils.update_buffer(buf, prev_lines, new_lines, srow, erow)
  end)

  if errno then
    if errno.cmd and errno.code and errno.stderr then
      errno = ('%s exited with code %d\n%s'):format(
        errno.cmd,
        errno.code,
        errno.stderr
      )
    elseif errno.reason then
      errno = errno.reason
    end
  end

  return errno
end

---@param buf integer
---@param formatter mossy.source.formatting
---@return true|any
local function do_impure_fmt(buf, formatter)
  local opts =
    vim.tbl_extend('force', utils.get_cmd(formatter, { buf = buf }), {
      env = formatter.env or {},
    })
  if not opts.cmd then
    vim.print(formatter)
    return error 'formatter is missing a cmd field'
  end
  local result, err = nio.process.run(opts)

  local errno = nil
  if err then
    errno = {}
    errno.code = result.pid
    errno.reason = formatter.cmd .. ' exited with errors'
    errno.cmd = formatter.cmd
    errno.stderr = err
    return err
  end

  vim.schedule(function()
    vim.api.nvim_buf_call(buf, function()
      local views = utils.save_views(buf)
      vim.api.nvim_command 'silent! edit!'
      utils.restore_views(views)
    end)
  end)
end

---@param buf integer
---@param range? mossy.utils.range
---@param formatter mossy.source.formatting
---@param props mossy.format.props
---@return true|any
function format.request(buf, range, formatter, props)
  local format_on_save = fmt_get_option(formatter, 'format_on_save')
  if format_on_save == nil then
    format_on_save = config.get().defaults.formatting.format_on_save
  end
  if props.autoformat and not format_on_save then
    return log.trace(('(%s) autoformat disabled'):format(formatter.name))
  end

  if range and not formatter.stdin then
    return log.warn(
      ('(%s) formatter cannot format range'):format(formatter.name)
    )
  end

  if formatter.cond and not formatter.cond { buf = buf, range = range } then
    return log.trace(('(%s) disabled by condition'):format(formatter.name))
  end

  if formatter.cmd and vim.fn.executable(formatter.cmd) == 0 then
    return log.warn(
      ('(%s) executable not found `%s`'):format(formatter.name, formatter.cmd)
    )
  end

  log.debug(('(%s) pending format'):format(formatter.name))

  local result = nil
  nio.run(function()
    if formatter.stdin or formatter.fn then
      log.debug(('(%s) using pure formatting'):format(formatter.name))
      result = do_pure_fmt(buf, range, formatter)
    else
      log.debug(('(%s) using impure formatting'):format(formatter.name))
      result = do_impure_fmt(buf, formatter)
    end
  end)

  if result and result ~= true then
    return log.error(result)
  end

  log.debug(('(%s) finished formatting'):format(formatter.name))

  return true
end

---@param buf integer
---@param range? mossy.utils.range
---@param props mossy.format.props
function format.lsp_format(buf, range, props)
  local formatter = require('mossy.builtins').get 'lsp'
  if not formatter then
    return log.debug 'lsp builtin formatter could not be found'
  end

  return format.request(buf, range, formatter, props)
end

---@param buf integer
---@param props mossy.format.props
function format.try(buf, props)
  local filetype = vim.filetype.match { buf = buf }
  if not filetype then
    log.warn 'unable to detect filetype'
    return
  end
  local formatters = ft.get(filetype, 'formatting')
  if #formatters == 0 then
    local msg = ("no formatters configured for filetype '%s'"):format(filetype)
    return log.warn(msg)
  end

  local range = nil
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'V' or mode == 'v' then
    range = utils.range_from_selection(buf, mode == 'V')
  end

  vim.iter(ipairs(formatters)):find(function(_, formatter)
    local result = format.request(buf, range, formatter, props)
    if result and result ~= true then
      log.debug(('error while formatting\n\t%s'):format(result))
      local use_lsp_fallback = fmt_get_option(formatter, 'use_lsp_fallback')
      if use_lsp_fallback then
        result = format.lsp_format(buf, range, props)
        if result and result ~= true then
          log.debug(('error while formatting\n\t%s'):format(result))
        end
      end
    end
  end)
end

return format
