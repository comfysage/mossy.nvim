---@type mossy.source.formatting
return {
	name = "just",
	method = "formatting",
	filetypes = { "just" },
	cmd = "just",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		return {
			"--fmt",
			"--unstable",
			"-f",
			filename,
		}
	end,
	stdin = false,
}
