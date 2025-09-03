local utils = require("mossy.utils")

---@type { [string]: mossy.source }
local builtins = {
  lsp = {
    name = "lsp",
    method = "formatting",
    fn = function(params)
      vim.lsp.buf.format({
        async = false,
        bufnr = params.buf,
        range = params.range,
      })
      return true
    end,
  },
}

return {
  get = function(name)
    local builtin = builtins[name]
    if builtin then
      return builtin
    end
    local ok, result = pcall(require, string.format("mossy.builtins.%s", name))
    if not ok then
      return
    end
    builtin = result
    return utils.parsecfg(builtin)
  end,
}
