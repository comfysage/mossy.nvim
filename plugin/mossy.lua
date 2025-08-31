vim.keymap.set("n", "<Plug>(mossy-format)", function()
  require("mossy").format()
end, { silent = true })

if vim.v.vim_did_enter > 0 then
  require("mossy").init()
else
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      require("mossy").init()
    end,
  })
end
