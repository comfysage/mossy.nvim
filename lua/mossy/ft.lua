---@diagnostic disable: missing-fields

local config = require("mossy.config")

local values = {}

---@class mossy.boxtbl.value
---@field formatters mossy.fmt.config[]
---@field format_on_save boolean

---@class mossy.boxtbl
---@field __index mossy.boxtbl
---@field value mossy.boxtbl.value
---@field get fun(self): mossy.boxtbl.value
---@field get_global fun(self, filetypes): { [string]: mossy.boxtbl.value }
---@field ft fun(self): string[]
---@field push fun(self): mossy.boxtbl
---@field fold fun(self): { [string]: mossy.boxtbl.value }
---@field use fun(self, cfg): mossy.boxtbl

-- creates a meta box as a wrapper for a ft
---@param ft string|string[]
local function box(ft)
	---@type mossy.boxtbl
	local tbl = {}
	tbl.__index = tbl

	---@cast ft string[]

	function tbl:get()
		return self.value
	end

	function tbl:get_global(filetypes)
		if filetypes and type(filetypes) ~= "table" then
			filetypes = { filetypes }
		end
		filetypes = filetypes or self:ft()

		local globalopts = config.get().globalopts
		return vim.iter(ipairs(filetypes)):fold({}, function(acc, _, thisfmt)
			local opts = config.get().formatters[thisfmt] or {}
			opts = vim.tbl_extend("keep", opts, globalopts)
			acc[thisfmt] = opts
			return acc
		end)
	end

	function tbl:ft()
		if type(ft) ~= "table" then
			return { ft }
		end
		return ft
	end

	-- push changes up to config
	function tbl:push()
		local newfmt = vim.iter(ipairs(self:ft())):fold({}, function(acc, _, thisft)
			acc[thisft] = self:get()
			return acc
		end)

		config.set(config.override({
			formatters = newfmt,
		}))
		return self
	end

	-- return formatters for this ft
	-- searches for exact match first,
	-- falls back on '*'
	function tbl:fold()
		local all = self:get_global("*")["*"]
		return vim.iter(pairs(self:get_global())):fold({}, function(acc, thisft, fmt)
			if not fmt.formatters then
				acc[thisft] = all
			else
				acc[thisft] = fmt
			end
			return acc
		end)
	end

	---@param cfg mossy.fmt.config|string
	local function parsecfg(cfg)
		if type(cfg) == "string" then
			local formatter = require("mossy.builtins").get(cfg)
			if formatter then
				return formatter
			end

			cfg = {
				cmd = cfg,
			}
		end
		if not cfg.args then
			cfg.args = {}
		end
		if cfg.stdin == nil then
			cfg.stdin = true
		end
		---@cast cfg mossy.fmt.config
		return cfg
	end

	function tbl:use(cfg)
		self.value.formatters[#self.value.formatters + 1] = parsecfg(cfg)
		return self:push()
	end

	return setmetatable({
		value = {
			formatters = {},
		},
	}, tbl)
end

---@type fun(ft: string|string[]): mossy.boxtbl
---@diagnostic disable-next-line: assign-type-mismatch
local _ft = setmetatable(values, {
	---@param _self {}
	---@param ft string|string[]
	---@return mossy.boxtbl
	__call = function(_self, ft)
		if not rawget(_self, ft) then
			rawset(_self, ft, box(ft))
		end
		return _self[ft]
	end,
})
return _ft
