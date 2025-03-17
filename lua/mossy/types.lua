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

---@generic T: mossy.method
---@generic C: mossy.diagnostics.config|mossy.formatting.config
---@generic P: mossy.diagnostics.params|mossy.formatting.params
---@class mossy.source<T, C, P>
---@field name string
---@field method T
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: P): string[]
---@field stdin? boolean only used for formatting
---@field fn? fun(params: P)
---@field env? { [string]: string }
---@field cond? fun(params: P)
---@field config? C
---@alias mossy.source.diagnostics mossy.source<'diagnostics', mossy.diagnostics.config, mossy.diagnostics.params>
---@alias mossy.source.formatting mossy.source<'formatting', mossy.formatting.config, mossy.formatting.params>

---@class mossy.diagnostics.config
---@class mossy.formatting.config
---@field format_on_save boolean

---@class mossy.diagnostics.params
---@field buf integer
---@class mossy.formatting.params
---@field buf integer
---@field range? mossy.utils.range

---@generic C: mossy.diagnostics.config|mossy.formatting.config
---@generic P: mossy.diagnostics.params|mossy.formatting.params
---@class mossy.source.opts<C, P>
---@field filetypes? string[]
---@field cmd? string
---@field args? string[]|fun(params: P): string[]
---@field stdin? boolean only used for formatting
---@field fn? fun(params: P)
---@field env? { [string]: string }
---@field cond? fun(params: P)
---@field config? C
---@alias mossy.source.diagnostics.opts mossy.source.opts<mossy.diagnostics.config, mossy.diagnostics.params>
---@alias mossy.source.formatting.opts mossy.source.opts<mossy.formatting.config, mossy.formatting.params>
