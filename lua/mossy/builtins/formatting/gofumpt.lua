---@type mossy.source.formatting
return {
  name = 'gofumpt',
  method = 'formatting',
  filetypes = { 'go' },
  cmd = 'gofumpt',
  stdin = true,
}
