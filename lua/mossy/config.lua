local M = {}

---@type mossy.config
M.default = {
	enable = true,
	globalopts = {
		format_on_save = true,
	},
	sources = {
		diagnostics = {},
		formatting = {},
	},
	per_filetype = {},
	log_level = vim.log.levels.INFO,
}

---@type mossy.config
M.config = {}

---@return mossy.config
function M.get()
	return vim.tbl_deep_extend("force", M.default, M.config)
end

---@param cfg mossy.config
---@return mossy.config
function M.override(cfg)
	return vim.tbl_deep_extend("force", M.default, cfg)
end

---@param cfg mossy.config
function M.set(cfg)
	M.config = cfg
end

return M
