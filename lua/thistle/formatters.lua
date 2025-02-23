---@type { [string]: fun(params: thistle.fmt.fn.params) }
local formatters = {
	lsp = function(params)
		vim.lsp.buf.format({ async = true, bufnr = params.buf, range = params.range })
	end,
}

return {
	get = function(name)
		return formatters[name]
	end,
}
