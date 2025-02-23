---@class thistle.config
---@field globalopts? thistle.globalopts
---@field formatters? { [string]: thistle.fmt.config }
---@field log_level? integer

---@class thistle.globalopts
---@field format_on_save boolean

---@class thistle.fmt.config
---@field cmd string
---@field args string[]
---@field fn? fun(params: thistle.fmt.fn.params)
---@field stdin boolean
---@field env? { [string]: string }

---@class thistle.fmt.fn.params
---@field buf integer
---@field range? thistle.utils.range
