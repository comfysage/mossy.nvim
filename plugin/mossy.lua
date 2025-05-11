vim.keymap.set('n', '<Plug>(mossy-format)', function()
  require('mossy').format()
end, { silent = true })

vim.api.nvim_create_autocmd('BufAdd', {
  group = vim.api.nvim_create_augroup('mossy.format:check', { clear = true }),
  callback = function(ev)
    require('mossy').init(ev.buf)
  end,
})
