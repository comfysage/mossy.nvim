---@module 'mossy.config'

local config = {}

---@type mossy.config
config.default = {
  enable = true,
  defaults = {
    format_on_save = true,
    use_lsp_fallback = true,
  },
  sources = {},
  log_level = vim.log.levels.INFO,
}

---@type mossy.config
config.current = {}

---@return mossy.config
function config.get()
  return vim.tbl_deep_extend("force", config.default, config.current)
end

---@param cfg mossy.config
---@return mossy.config
function config.override(cfg)
  return vim.tbl_deep_extend("force", config.default, cfg)
end

---@param cfg mossy.config
function config.set(cfg)
  config.current = cfg
end

return config
