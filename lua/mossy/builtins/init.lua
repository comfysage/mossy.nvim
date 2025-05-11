local utils = require 'mossy.utils'

---@type { [string]: mossy.source }
local builtins = {
  lsp = {
    name = 'lsp',
    method = 'formatting',
    fn = function(params)
      vim.lsp.buf.format {
        async = false,
        bufnr = params.buf,
        range = params.range,
      }
    end,
  },
}

return {
  get = function(name)
    local builtin = builtins[name]
    if builtin then
      return builtin
    end
    vim.iter({ 'diagnostics', 'formatting' }):find(function(method)
      local ok, result =
        pcall(require, string.format('mossy.builtins.%s.%s', method, name))
      if not ok then
        return
      end
      builtin = result
      return true
    end)
    return utils.parsecfg(builtin)
  end,
}
