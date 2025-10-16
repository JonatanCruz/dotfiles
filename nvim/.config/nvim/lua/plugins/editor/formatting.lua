-- ============================================================================
-- Conform - Formateo automático de código
-- ============================================================================
-- Formatea código automáticamente al guardar con soporte para múltiples
-- formateadores por tipo de archivo.
-- Documentación: https://github.com/stevearc/conform.nvim
-- ============================================================================

local constants = require("config.constants")

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = {
      timeout_ms = constants.formatting.timeout_ms,
      lsp_fallback = constants.formatting.lsp_fallback,
    },
  },
}
