if vim.g.loaded_mossy then
  return
end

vim.g.loaded_mossy = true

vim.keymap.set("n", "<Plug>(mossy-format)", function()
  require("mossy").format()
end, {})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("mossy.autoformat", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    if require("mossy.config").get().enable then
      require("mossy").format(ev.buf, { autoformat = true })
    end
  end,
})
