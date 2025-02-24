---@class mossy.config
---@field globalopts? mossy.globalopts
---@field formatters? { [string]: mossy.fmt.config }
---@field log_level? integer

---@class mossy.globalopts
---@field format_on_save boolean

---@class mossy.fmt.config
---@field cmd? string
---@field args? string[]|fun(params: mossy.fmt.params): string[]
---@field fn? fun(params: mossy.fmt.params)
---@field stdin? boolean
---@field env? { [string]: string }
---@field cond? fun(params: mossy.fmt.params)

---@class mossy.fmt.params
---@field buf integer
---@field range? mossy.utils.range
