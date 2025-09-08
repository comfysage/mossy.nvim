local config = require("mossy.config")
local log = require("mossy.log")
local utils = require("mossy.utils")

---@class mossy.proto.sources
---@field __index mossy.proto.sources
---@field value mossy.config.sources
---@field lastsource? string

---@type mossy.proto.sources
---@diagnostic disable-next-line: missing-fields
local sources = {}
sources.__index = sources

---@class mossy.proto.sources
---@field get fun(): mossy.config.sources
function sources:get()
  if not self.value then
    self.value = {}
  end
  return self.value
end

---@class mossy.proto.sources
---@field push fun(): mossy.proto.sources
function sources:push()
  config.set(config.override({
    sources = vim.tbl_extend("force", config.get().sources, self:get()),
  }))
  return self
end

---@class mossy.proto.sources
---@field add fun(self, cfg: mossy.source|string): mossy.proto.sources
function sources:add(cfg)
  local vcfg, err = utils.parsecfg(cfg)
  if err then
    return
  end
  if not vcfg then
    return self
  end
  self:get()[vcfg.name] = vcfg
  log.debug(string.format("(%s) config initialized", vcfg.name))
  self.lastsource = vcfg.name
  return self:push()
end

---@class mossy.proto.sources
---@field with fun(self, cfg: mossy.source): mossy.proto.sources
function sources:with(cfg)
  if not self.lastsource or not vim.tbl_get(self:get(), self.lastsource) then
    return log.error("no source found to override")
  end
  local source = vim.tbl_get(self:get(), self.lastsource)
  self:get()[source.name] = vim.tbl_deep_extend("force", source, cfg)
  return self:push()
end

---@class mossy.proto.sources
---@field setup fun(self, src: mossy.source|string[])
function sources:setup(src)
  vim.iter(ipairs(src)):each(function(_, cfg)
    self:add(cfg)
  end)
  return self
end

return setmetatable({}, sources)
