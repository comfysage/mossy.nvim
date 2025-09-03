---@class mossy.config
---@field enable? boolean
---@field defaults? mossy.source.config
---@field sources? mossy.config.sources
---@field log_level? integer

---@alias mossy.config.sources table<string, mossy.source>

---@class mossy.source
---@field name string
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: mossy.callback.params): string[]
---@field stdin? boolean
---@field on_output? fun(output: string): string
---@field fn? fun(params: mossy.callback.params): string[]|boolean
---@field env? { [string]: string }
---@field cond? fun(params: mossy.callback.params)
---@field config? mossy.source.config

---@class mossy.source.config
---@field format_on_save boolean
---@field use_lsp_fallback boolean

---@class mossy.callback.params
---@field buf integer
---@field range? mossy.utils.range
