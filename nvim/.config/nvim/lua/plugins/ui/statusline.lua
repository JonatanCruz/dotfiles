-- ============================================================================
-- Lualine - Barra de estado elegante
-- ============================================================================
-- Statusline moderna con soporte de íconos y temas.
-- Documentación: https://github.com/nvim-lualine/lualine.nvim
-- ============================================================================

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "catppuccin",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
  },
}
