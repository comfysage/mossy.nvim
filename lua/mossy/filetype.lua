local ft = {}

---@param filetype string
---@return mossy.source[]
function ft.get(filetype)
  return vim
    .iter(pairs(require("mossy.config").get().sources))
    :map(function(_, cfg)
      if not cfg.filetypes or vim.tbl_contains(cfg.filetypes, filetype) then
        return cfg
      end
    end)
    :totable()
end

return ft
