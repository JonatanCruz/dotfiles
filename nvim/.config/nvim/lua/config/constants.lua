-- ============================================================================
-- Constantes compartidas
-- ============================================================================
-- Valores que consumen varios módulos de la config. Solo vive aquí lo que
-- alguien lee de verdad: si añades una sección, asegúrate de que se usa, o
-- acabará divergiendo del fichero que sí se ejecuta.
-- ============================================================================

local M = {}

-- Bordes de ventanas flotantes. Lo usan cmp.lua y noice.lua.
M.borders = {
  style = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  chars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

-- Formateo (conform.nvim). Lo usa formatting.lua.
M.formatting = {
  timeout_ms = 500,
  -- conform >= 2024: reemplaza al antiguo lsp_fallback
  lsp_format = "fallback",
  async = false,
}

-- Parsers de Treesitter. Lo usa treesitter.lua.
M.treesitter = {
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

return M
