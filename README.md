# mossy.nvim

 ## :sparkles: features
 
a simple and opinionated development plugin.

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
- [guard.nvim](https://github.com/nvimdev/guard.nvim) - Lightweight, fast and async formatting and linting plugin for Neovim

## :lock: requirements

- Neovim `>= 0.10.0`

## :package: installation

mossy can be installed by adding *this* to your `lua/plugins/init.lua`:

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
	globalopts = {
		format_on_save = true,
	},
	formatters = {},
	log_level = vim.log.levels.INFO,
}
```
