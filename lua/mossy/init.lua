local config = require 'mossy.config'

local M = {}

---@param cfg? mossy.config
function M.setup(cfg)
  cfg = cfg or {}
  config.set(config.override(cfg))

  vim.api.nvim_create_autocmd('BufAdd', {
    group = vim.api.nvim_create_augroup('mossy.format:check', { clear = true }),
    callback = function(ev)
      require('mossy').init(ev.buf)
    end,
  })
end

---@param buf? integer
function M.init(buf)
  buf = buf or 0

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup(
      ('mossy.format[%d]'):format(buf),
      { clear = true }
    ),
    callback = function(ev)
      if config.get().enable then
        require('mossy').format(ev.buf, { autoformat = true })
      end
    end,
    buffer = buf,
  })
end

function M.disable()
  config.set(config.override { enable = false })
end

function M.enable()
  config.set(config.override { enable = true })
end

function M.toggle()
  if config.get().enable then
    M.disable()
  else
    M.enable()
  end
end

---@class mossy.format.props
---@field autoformat? true

---@param buf? integer
---@param props? mossy.format.props
function M.format(buf, props)
  buf = buf or 0
  return require('mossy.format').format(buf, props or {})
end

return M
