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

---@class mossy.source
---@field name string
---@field method mossy.method
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: mossy.diagnostics.params|mossy.formatting.params): string[]
---@field stdin? boolean only used for formatting
---@field on_output? fun(output: string): string
---@field fn? fun(params: mossy.diagnostics.params|mossy.formatting.params)
---@field env? { [string]: string }
---@field cond? fun(params: mossy.diagnostics.params|mossy.formatting.params)
---@field config? mossy.diagnostics.config|mossy.formatting.config

---@class mossy.source.diagnostics : mossy.source
---@field method 'diagnostics'
---@field config? mossy.diagnostics.config
---@field args? string[]|fun(params: mossy.diagnostics.params): string[]
---@field fn? fun(params: mossy.diagnostics.params)
---@field cond? fun(params: mossy.diagnostics.params)

---@class mossy.source.formatting : mossy.source
---@field method 'formatting'
---@field config? mossy.formatting.config
---@field args? string[]|fun(params: mossy.formatting.params): string[]
---@field fn? fun(params: mossy.formatting.params)
---@field cond? fun(params: mossy.formatting.params)

---@class mossy.diagnostics.config
---@class mossy.formatting.config
---@field format_on_save boolean
---@field use_lsp_fallback boolean

---@class mossy.diagnostics.params
---@field buf integer
---@class mossy.formatting.params
---@field buf integer
---@field range? mossy.utils.range
