-- ============================================================================
-- Constantes compartidas
-- ============================================================================
-- Valores constantes usados en múltiples partes de la configuración.
-- Centralizar estos valores facilita su mantenimiento y consistencia.
-- ============================================================================

local error_handler = require("utils.error_handler")
local icons = error_handler.safe_require("utils.icons", {})
local colors = error_handler.safe_require("utils.colors", {})

local M = {}

-- Configuración de bordes para ventanas flotantes
M.borders = {
  style = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  chars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- Caracteres personalizados
}

-- Configuración de transparencia
M.transparency = {
  enabled = true,
  background_color = "#000000",
  winblend = 0, -- 0 = completamente transparente, 100 = completamente opaco
}

-- Configuración de iconos (re-exportar para fácil acceso)
M.icons = icons

-- Configuración de colores (re-exportar para fácil acceso)
M.colors = colors

-- Configuración de UI
M.ui = {
  -- Ancho de columnas
  sign_column_width = 2,
  number_column_width = 4,

  -- Tamaños de ventanas
  sidebar_width = 30,
  preview_height = 15,

  -- Timeouts
  timeout = 300, -- Para which-key y otros
  update_time = 250, -- Para actualizaciones rápidas

  -- Scrolloff
  scroll_offset = 8,

  -- Splits
  split_ratio = 0.5,
}

-- Configuración de LSP
M.lsp = {
  -- Iconos de diagnósticos
  signs = {
    { name = "DiagnosticSignError", text = icons.diagnostics.error },
    { name = "DiagnosticSignWarn", text = icons.diagnostics.warn },
    { name = "DiagnosticSignHint", text = icons.diagnostics.hint },
    { name = "DiagnosticSignInfo", text = icons.diagnostics.info },
  },

  -- Configuración de diagnósticos
  diagnostic_config = {
    virtual_text = {
      prefix = "●",
      spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = M.borders.style,
      source = "always",
      header = "",
      prefix = "",
    },
  },

  -- Formato de hover
  hover = {
    border = M.borders.style,
    max_width = 80,
    max_height = 20,
  },
}

-- Configuración de formateo
M.formatting = {
  -- Timeout para formateo
  timeout_ms = 500,

  -- Usar LSP como fallback
  lsp_fallback = true,

  -- Formateo asíncrono
  async = false,
}

-- Configuración de completado
M.completion = {
  -- Número mínimo de caracteres para mostrar completado
  keyword_length = 1,

  -- Número máximo de items en el menú
  max_items = 10,

  -- Documentación
  documentation = {
    border = M.borders.style,
    max_width = 80,
    max_height = 20,
  },
}

-- Rutas importantes
M.paths = {
  config = vim.fn.stdpath("config"),
  data = vim.fn.stdpath("data"),
  cache = vim.fn.stdpath("cache"),
  lazy = vim.fn.stdpath("data") .. "/lazy",
}

-- Providers deshabilitados (para mejorar rendimiento)
M.disabled_providers = {
  "node",
  "perl",
  "python3",
  "ruby",
}

-- Plugins integrados de Neovim a deshabilitar
M.disabled_builtin_plugins = {
  "gzip",
  "matchit",
  "matchparen",
  "netrwPlugin",
  "tarPlugin",
  "tohtml",
  "tutor",
  "zipPlugin",
}

-- Configuración de Git
M.git = {
  -- Signos de cambios
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },

  -- Colores
  colors = colors.git_colors,
}

-- Configuración de Treesitter
M.treesitter = {
  -- Lenguajes a instalar automáticamente
  ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "javascript",
    "typescript",
    "html",
    "css",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
    "bash",
  },
}

-- Configuración de terminal
M.terminal = {
  -- Shell por defecto
  shell = vim.o.shell,

  -- Tamaño de terminal flotante
  float_size = {
    width = 0.8,
    height = 0.8,
  },
}

return M
