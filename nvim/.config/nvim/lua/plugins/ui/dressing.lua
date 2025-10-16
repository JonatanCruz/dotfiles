-- ============================================================================
-- Dressing - UI mejorada para inputs y selects
-- ============================================================================
-- Mejora los inputs y selects nativos de Vim con integración de Telescope.
-- Documentación: https://github.com/stevearc/dressing.nvim
-- ============================================================================

return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    input = {
      enabled = true,
      default_prompt = "➤ ",
      win_options = {
        winblend = 0,
      },
    },
    select = {
      enabled = true,
      backend = { "telescope", "builtin" },
      builtin = {
        win_options = {
          winblend = 0,
        },
      },
    },
  },
}
