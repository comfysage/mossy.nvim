local log = require("mossy.log")

---@type { [string]: mossy.fmt.config }
local formatters = {
	lsp = {
		fn = function(params)
			vim.lsp.buf.format({ async = true, bufnr = params.buf, range = params.range })
		end,
	},
}

return {
	get = function(name)
		local formatter = formatters[name]
		if formatter then
			return formatter
		end
		local ok, result = pcall(require, string.format("mossy.builtins.%s", name))
		if not ok then
			return
		end
		return result
	end,
}
