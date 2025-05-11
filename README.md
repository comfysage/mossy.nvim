# mossy.nvim

:mushroom: a simple and opinionated development plugin.

```lua
local ft = require("mossy.ft")
-- use formatters for your favourite languages
ft("lua"):use("stylua")
ft("nix"):use("nixfmt")

-- add a formatter for multiple languages
ft({ "html", "astro", "vue" }):use("prettier")

-- add a default formatter for all languages
ft("*"):use({
  cmd = "treefmt",
  args = function(params)
    local filename = vim.api.nvim_buf_get_name(params.buf)
    return { "--allow-missing-formatter", "--stdin", filename }
  end,
})
```

inspired by:
- [none-ls](https://github.com/nvimtools/none-ls.nvim) - Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
- [guard.nvim](https://github.com/nvimdev/guard.nvim) - Lightweight, fast and async formatting and linting plugin for Neovim

## :sparkles: features

- [x] `ft()`: easy declaration of formatters for each filetype
- [x] `ft():use()`: ordered formatter declaration
- [x] `formatter.args`: dynamic arguments for formatters
- [x] `formatter.cond`: conditional formatters: use a predicate to enable formatter
- [ ] lsp fallback: use an lsp server to format the file if others failed
- [ ] *linters*: support for lsp linters
- [ ] *nvim events*: use autocmds to extend mossy's behaviour

## :lock: requirements

- Neovim `>= 0.10.0`

## :package: installation

mossy can be installed by adding this to your `lua/plugins/init.lua`:

```lua
{
  'comfysage/mossy.nvim',
  after = function()
    require 'mossy'.setup()
    vim.keymap.set('n', '<localleader>f', require('mossy').format)
  end,
}
```

## :gear: configuration

Below is the default configuration.

```lua
{
	enable = true,
	defaults = {
		formatting = {
			format_on_save = true,
			use_lsp_fallback = true,
		},
		diagnostics = {},
	},
	log_level = vim.log.levels.INFO,
}
```
