rockspec_format = "3.0"
package = "mossy.nvim"
version = "dev-1"
source = {
  url = "git://github.com/comfysage/" .. package,
}
description = {
  summary = ":mushroom: a simple and opinionated development plugin.",
  detailed = [[
  :mushroom: a simple and opinionated development plugin.
  ]],
  homepage = "https://github.com/comfysage/" .. package,
  labels = { 'neovim' },
  license = "GPL3"
}
build = {
  type = "builtin",
  copy_directories = {
    'doc'
  }
}
dependencies = {
  'lua >= 5.1',
  'nvim-nio',
}
