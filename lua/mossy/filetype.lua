local filetype = {}

---@param ft string
---@return mossy.source[]
function filetype.get(ft)
  return vim
    .iter(pairs(require("mossy.config").get().sources))
    :map(function(_, cfg)
      if not cfg.filetypes or vim.tbl_contains(cfg.filetypes, ft) then
        return cfg
      end
    end)
    :totable()
end

return filetype
