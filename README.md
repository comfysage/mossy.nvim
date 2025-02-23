# thistle.nvim

## :sparkles: features

a quick and easy formatting plugin.

```lua
local ft = require("thistle.ft")
ft("*"):use("prettier")
ft("lua"):use("stylua")
```

inspired by:
- [guard.nvim](https://github.com/nvimdev/guard.nvim) - Lightweight, fast and async formatting and linting plugin for Neovim

## :lock: requirements

- Neovim `>= 0.10.0`

## :package: installation

Thistle can be installed by adding *this* to your `lua/plugins/init.lua`:

```lua
{
  'comfysage/thistle.nvim',
  after = function()
    require 'thistle'.setup()
    vim.keymap.set('n', '<localleader>f', require('thistle').format)
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
