local minidoc = require('mini.doc')

if _G.MiniDoc == nil then minidoc.setup() end

local hooks = vim.deepcopy(MiniDoc.default_hooks)

hooks.write_pre = function(lines)
  -- Remove first two lines with `======` and `------` delimiters to comply
  -- with `:h local-additions` template
  table.remove(lines, 1)
  table.remove(lines, 1)
  return lines
end

local function is_init(str)
  return string.sub(str, -8) == 'init.lua'
end

local function cmp_path(a, b)
  a, b = tostring(a), tostring(b)

  if is_init(a) then
    return true
  end
  if is_init(b) then
    return false
  end
  return a:lower() < b:lower()
end

-- init

local init_base = 'lua/mossy'

local init_mods = vim.iter(vim.fs.dir(init_base)):map(function(modfile, ftype)
  if ftype == 'file' then
    return vim.fs.joinpath(init_base, modfile)
  end
end):totable()
table.sort(init_mods, cmp_path)

minidoc.generate(init_mods, 'doc/mossy.txt', { hooks = hooks })

-- builtins

local builtin_base = init_base .. '/builtins'

local builtin_mods = vim.iter(vim.fs.dir(builtin_base)):map(function(modfile, ftype)
  if ftype == 'directory' then
    return modfile
  end
end):fold({}, function(acc, builtin_type)
  local files = vim.iter(vim.fs.dir(vim.fs.joinpath(builtin_base, builtin_type))):map(function(modfile, ftype)
    if ftype == 'file' then
      return vim.fs.joinpath(builtin_base, builtin_type, modfile)
    end
  end):totable()
  table.sort(files, cmp_path)
  acc[builtin_type] = files
  return acc
end)

vim.iter(pairs(builtin_mods)):each(function(builtin_type, modfiles)
  minidoc.generate(modfiles, 'doc/mossy-builtins-' .. builtin_type .. '.txt', { hooks = hooks })
end)
