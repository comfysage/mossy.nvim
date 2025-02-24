local config = require("mossy.config")

local ft = {}

---@param filetype string
---@return mossy.config.sources
function ft.get_all(filetype)
	return vim.iter(ipairs(vim.tbl_keys(config.get().sources))):fold({}, function(acc, _, method)
		acc[method] = ft.get(filetype, method)
		return acc
	end)
end

---@param filetype string
---@param method? 'diagnostics'|'formatting'
---@return mossy.source[]
function ft.get(filetype, method)
	if not method then
		return ft.get_all(filetype)
	end

	return vim.iter(pairs(config.get().sources[method]))
		:map(function(_, cfg)
			if not cfg.filetypes or vim.tbl_contains(cfg.filetypes, filetype) then
				return cfg
			end
		end)
		:totable()
end

return ft
