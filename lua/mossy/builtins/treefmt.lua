return {
	cmd = "treefmt",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		return { "--allow-missing-formatter", "--stdin", filename }
	end,
	cond = function()
		return vim.fs.root(0, "treefmt.toml")
	end,
}
