--- *mossy.nvim*
---
--- ==============================================================================
---
--- # mossy.nvim
---
--- :mushroom: a simple and opinionated development plugin.
---
--- ```lua
--- local ft = require("mossy.ft")
--- -- use formatters for your favourite languages
--- ft("lua"):use("stylua")
--- ft("nix"):use("nixfmt")
---
--- -- add a formatter for multiple languages
--- ft({ "html", "astro", "vue" }):use("prettier")
---
--- -- add a default formatter for all languages
--- ft("*"):use({
---   cmd = "treefmt",
---   args = function(params)
---     local filename = vim.api.nvim_buf_get_name(params.buf)
---     return { "--allow-missing-formatter", "--stdin", filename }
---   end,
--- })
--- ```
---
--- inspired by:
--- - [none-ls](https://github.com/nvimtools/none-ls.nvim) - Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
--- - [guard.nvim](https://github.com/nvimdev/guard.nvim) - Lightweight, fast and async formatting and linting plugin for Neovim
---
--- ## :sparkles: features
---
--- - [x] `ft()`: easy declaration of formatters for each filetype
--- - [x] `ft():use()`: ordered formatter declaration
--- - [x] `formatter.args`: dynamic arguments for formatters
--- - [x] `formatter.cond`: conditional formatters: use a predicate to enable formatter
--- - [ ] lsp fallback: use an lsp server to format the file if others failed
--- - [ ] *linters*: support for lsp linters
--- - [ ] *nvim events*: use autocmds to extend mossy's behaviour
---
--- ## :lock: requirements
---
--- - Neovim `>= 0.10.0`
--- - [nvim-nio](https://github.com/nvim-neotest/nvim-nio)
---
--- ## :package: installation
---
--- mossy can be installed by adding this to your `lua/plugins/init.lua`:
---
--- ```lua
--- {
---   'comfysage/mossy.nvim',
---   after = function()
---     require 'mossy'.setup()
---     vim.keymap.set('n', '<localleader>f', require('mossy').format)
---   end,
--- }
--- ```
---
--- ## :gear: configuration
---
--- Below is the default configuration.
---
--- ```lua
--- {
--- 	enable = true,
--- 	defaults = {
--- 		formatting = {
--- 			format_on_save = true,
--- 			use_lsp_fallback = true,
--- 		},
--- 		diagnostics = {},
--- 	},
--- 	log_level = vim.log.levels.INFO,
--- }
--- ```

local config = require 'mossy.config'

local mossy = {}

---@param cfg? mossy.config
function mossy.setup(cfg)
  cfg = cfg or {}
  config.set(config.override(cfg))
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
      if require('mossy.config').get().enable then
        require('mossy').format(ev.buf, { autoformat = true })
      end
    end,
    buffer = buf,
  })
end

function mossy.disable()
  config.set(vim.tbl_deep_extend('force', config.get(), { enable = false }))
end

function mossy.enable()
  config.set(vim.tbl_deep_extend('force', config.get(), { enable = true }))
end

function mossy.toggle()
  if require("mossy.config").get().enable then
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
