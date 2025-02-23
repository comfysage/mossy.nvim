local M = {}

---@type thistle.config
M.default = {
	globalopts = {
		format_on_save = true,
	},
	formatters = {},
	log_level = vim.log.levels.INFO,
}

---@type thistle.config
M.config = {}

---@return thistle.config
function M.get()
	return vim.tbl_deep_extend("force", M.default, M.config)
end

---@param cfg thistle.config
---@return thistle.config
function M.override(cfg)
	return vim.tbl_deep_extend("force", M.default, cfg)
end

---@param cfg thistle.config
function M.set(cfg)
	M.config = cfg
end

return M
