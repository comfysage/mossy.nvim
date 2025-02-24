---@type mossy.source.formatting
return {
	name = "shfmt",
	method = "formatting",
	cmd = "shfmt",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		return { "-filename", filename }
	end,
	stdin = true,
}
