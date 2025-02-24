return {
	cmd = "shfmt",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		return { "-filename", filename }
	end,
	stdin = true,
}
