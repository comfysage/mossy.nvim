R = function(m, ...)
  require("plenary.reload").reload_module(m, ...)
  return require(m)
end

vim.opt.rtp:prepend(".")

vim.cmd.packadd("mossy.nvim")

require("mossy.config").current.log_level = vim.log.levels.TRACE
