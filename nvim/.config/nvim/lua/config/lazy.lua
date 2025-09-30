local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Carga las opciones y atajos ANTES de los plugins
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Configuración de Lazy
require('lazy').setup({
  -- La magia está aquí: lazy.nvim buscará y cargará todos los archivos .lua
  -- que encuentre en la carpeta 'lua/plugins/'.
  spec = {
    { import = 'plugins' },
  },
  -- Opciones adicionales de lazy.nvim si las necesitas
  change_detection = {
    enabled = true,
    notify = false,
  },
})
