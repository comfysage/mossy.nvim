local config = require 'mossy.config'

local mossy = {}

---@param cfg? mossy.config
function mossy.setup(cfg)
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
function mossy.init(buf)
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

function mossy.disable()
  config.set(config.override { enable = false })
end

function mossy.enable()
  config.set(config.override { enable = true })
end

function mossy.toggle()
  if config.get().enable then
    mossy.disable()
  else
    mossy.enable()
  end
end

---@class mossy.format.props
---@field autoformat? true

---@param buf? integer
---@param props? mossy.format.props
function mossy.format(buf, props)
  buf = buf or 0
  return require('mossy.format').try(buf, props or {})
end

return mossy
