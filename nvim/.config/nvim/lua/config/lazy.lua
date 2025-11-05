-- ============================================================================
-- CONFIGURACIÓN DE LAZY.NVIM
-- ============================================================================
-- Gestor de plugins moderno para Neovim

-- ============================================================================
-- INSTALACIÓN AUTOMÁTICA DE LAZY.NVIM
-- ============================================================================

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

-- ============================================================================
-- CARGA DE CONFIGURACIÓN BASE
-- ============================================================================
-- Se cargan ANTES de los plugins para que estén disponibles

local error_handler = require('utils.error_handler')

local core_modules = {
  'config.globals',      -- Variables globales
  'config.options',      -- Opciones de Neovim
  'config.keymaps',      -- Keymaps generales
  'config.autocmds',     -- Autocomandos
  'config.diagnostics',  -- Configuración de diagnósticos LSP
}

for _, module in ipairs(core_modules) do
  error_handler.safe_require(module)
end

-- ============================================================================
-- CONFIGURACIÓN DE LAZY
-- ============================================================================

require('lazy').setup({
  -- Importa automáticamente todos los archivos .lua de lua/plugins/
  spec = {
    { import = 'plugins' },
    { import = 'plugins.ui' },
    { import = 'plugins.editor' },
    { import = 'plugins.coding' },
    { import = 'plugins.lsp' },
    { import = 'plugins.git' },
    { import = 'plugins.tools' },
    { import = 'plugins.debug' },
  },

  -- ============================================================================
  -- OPCIONES DE LAZY.NVIM
  -- ============================================================================

  -- Detecta cambios en archivos de configuración y recarga automáticamente
  change_detection = {
    enabled = true,
    notify = false,  -- No mostrar notificación al recargar
  },

  -- Mejoras de rendimiento
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      -- Deshabilita plugins predeterminados que no usamos
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },

  -- Interfaz de usuario
  ui = {
    border = 'rounded',  -- Bordes redondeados en la ventana de lazy
  },
})
