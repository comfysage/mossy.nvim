local h = require("mossy.helpers")

---@type mossy.source.formatting
return {
	name = "clang-format",
	method = "formatting",
	filetypes = { "c", "cpp", "cs", "java", "cuda", "proto" },
	cmd = "clang-format",
	args = function(params)
		local filename = vim.api.nvim_buf_get_name(params.buf)
		local args = h.make_args_range(
			{
				"-assume-filename",
				filename,
			},
			"--offset",
			"--length",
			{
				use_length = true,
				row_offset = -1,
				col_offset = -1,
			}
		)(params)
		if not vim.fs.root(0, ".clang-format") then
			vim.list_extend(args, {
				("--style={BasedOnStyle: llvm, IndentWidth: %d, TabWidth: %d, UseTab: %s}"):format(
					vim.bo.shiftwidth,
					vim.bo.tabstop,
					vim.bo.expandtab and "Never" or "Always"
				),
			})
		end
		return args
	end,
}
