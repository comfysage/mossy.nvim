---@diagnostic disable: redefined-local

local ok, plenary = pcall(require, "plenary.reload")

if not ok then
	return
end

plenary.reload_module("mossy")

require("mossy").setup()

local ft = require("mossy.ft")
ft("lua"):use("stylua")
-- local ft_all = ft("*"):use("prettier"):get()
-- return ft("toml"):fold()
-- return ft("lua"):fold()
return require("mossy").format()
