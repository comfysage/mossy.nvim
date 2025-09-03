---@type mossy.source
return {
  name = "treefmt",
  cmd = "treefmt",
  args = function(params)
    local filename = vim.api.nvim_buf_get_name(params.buf)
    return { "--allow-missing-formatter", "--stdin", filename }
  end,
  cond = function(_)
    return vim.fs.root(0, "treefmt.toml")
  end,
}
