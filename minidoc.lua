local minidoc = require("mini.doc")

if MiniDoc == nil then
  minidoc.setup()
end

local modname = "mossy"
local init_base = "lua/" .. modname

local current = {}
current.modules = {}

local hooks = vim.deepcopy(MiniDoc.default_hooks)

hooks.write_pre = function(lines)
  -- Remove first two lines with `======` and `------` delimiters to comply
  -- with `:h local-additions` template
  table.remove(lines, 1)
  table.remove(lines, 1)
  return lines
end

local function module_register(s)
  if #s == 0 then
    return
  end

  -- Remove first word (with bits of surrounding whitespace) while capturing it
  local mod
  s[1] = s[1]:gsub("%s*'(%S+)' ?", function(x)
    mod = x
    return ""
  end, 1)
  if mod == nil then
    return
  end

  local f = vim.tbl_get(s, "parent", "parent")
  if not f then
    return
  end

  current.modules[f.info.path] = current.modules[f.info.path] or {}
  current.modules[f.info.path].mod = mod
end

local function modpattern(name)
  return "%f[%w_]" .. name .. "%f[^%w_]"
end

local function module_replace(s)
  local f = vim.tbl_get(s, "parent", "parent")
  if not f then
    return
  end

  current.modules[f.info.path] = current.modules[f.info.path] or {}
  local name = current.modules[f.info.path].name
  if name == nil then
    name = string.gsub(vim.fs.basename(f.info.path), "%.lua$", "")
    current.modules[f.info.path].name = name
  end
  local mod = current.modules[f.info.path].mod
  if mod == nil then
    mod = modname .. "." .. name
  end

  s[1] = string.gsub(s[1], modpattern(name), mod)
  s[1] = string.gsub(s[1], modpattern("M"), mod)
end

hooks.sections["@module"] = function(s)
  module_register(s)
end

hooks.section_pre = function(s)
  MiniDoc.default_hooks.section_pre(s)

  module_replace(s)
end

hooks.file = function(f)
  MiniDoc.default_hooks.file(f)

  current.modules[f.info.path] = {
    name = string.gsub(vim.fs.basename(f.info.path), "%.lua$", ""),
  }
end

-- init

vim
  .iter(vim.fs.dir(init_base))
  :map(function(modfile, ftype)
    if ftype == "file" then
      return {
        name = string.gsub(vim.fs.basename(modfile), "%.lua$", ""),
        path = vim.fs.joinpath(init_base, modfile),
      }
    end
  end)
  :each(function(mod)
    local name = modname
    if name ~= "init" then
      name = name .. "-" .. mod.name
    end
    minidoc.generate({ mod.path }, "doc/" .. name .. ".txt", { hooks = hooks })
  end)

-- builtins

local builtin_base = init_base .. "/builtins"

local modfiles = vim
  .iter(vim.fs.dir(builtin_base))
  :map(function(modfile, ftype)
    if ftype ~= "file" or modfile == "init.lua" then
      return
    end
    return vim.fs.joinpath(builtin_base, modfile)
  end)
  :totable()

minidoc.generate(modfiles, "doc/mossy-builtins.txt", { hooks = hooks })
