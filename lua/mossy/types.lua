---@class mossy.config
---@field enable? boolean
---@field defaults? mossy.config.defaults
---@field sources? mossy.config.sources
---@field log_level? integer

---@alias mossy.method 'diagnostics'|'formatting'

---@class mossy.config.defaults
---@field diagnostics mossy.diagnostics.config
---@field formatting mossy.formatting.config

---@class mossy.config.sources
---@field diagnostics table<string, mossy.source.diagnostics>
---@field formatting table<string, mossy.source.formatting>

---@alias mossy.source mossy.source.diagnostics|mossy.source.formatting
---@class mossy.source.diagnostics
---@field name string
---@field method 'diagnostics'
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: mossy.diagnostics.params): string[]
---@field fn? fun(params: mossy.diagnostics.params)
---@field env? { [string]: string }
---@field cond? fun(params: mossy.diagnostics.params)
---@field config? mossy.diagnostics.config
---@class mossy.source.formatting
---@field name string
---@field method 'formatting'
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: mossy.formatting.params): string[]
---@field fn? fun(params: mossy.formatting.params)
---@field stdin? boolean
---@field env? { [string]: string }
---@field cond? fun(params: mossy.formatting.params)
---@field config? mossy.formatting.config

---@class mossy.diagnostics.config
---@class mossy.formatting.config
---@field format_on_save boolean

---@class mossy.diagnostics.params
---@field buf integer
---@class mossy.formatting.params
---@field buf integer
---@field range? mossy.utils.range
