-- ============================================================================
-- lazydev.nvim - Neovim Lua API completion (reemplaza neodev.nvim, EOL)
-- ============================================================================
-- Provee autocompletado, documentación y type checking para configuración Lua.
-- Requiere Neovim >= 0.10. Compatible con vim.lsp.config (0.11+).
-- Documentación: https://github.com/folke/lazydev.nvim
-- ============================================================================

return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "nvim-dap-ui", words = { "dapui" } },
    },
  },
}
