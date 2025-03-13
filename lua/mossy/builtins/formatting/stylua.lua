local h = require("mossy.helpers")

---@type mossy.source.formatting
return {
	name = "stylua",
	method = "formatting",
	filetypes = { "lua", "luau" },
	cmd = "stylua",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		return h.make_args_range({
			"--search-parent-directories",
			"--stdin-filepath",
			filename,
			"-",
		}, "--range-start", "--range-end", { row_offset = -1, col_offset = -1 })(params)
	end,
}
