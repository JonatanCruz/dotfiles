-- ============================================================================
-- Supermaven - Autocompletado AI
-- ============================================================================
-- Autocompletado impulsado por IA en tiempo real. Gratuito con 1M token context.
-- Documentación: https://github.com/supermaven-inc/supermaven-nvim
--
-- Comandos útiles:
-- :SupermavenStart    - Iniciar Supermaven
-- :SupermavenStop     - Detener Supermaven
-- :SupermavenToggle   - Toggle Supermaven
-- :SupermavenUseFree  - Usar tier gratuito (primera vez)
-- :SupermavenShowLog  - Ver logs
-- ============================================================================

local colors = require("utils.colors")

return {
  "supermaven-inc/supermaven-nvim",
  event = "VeryLazy", -- Carga temprana para que los comandos estén disponibles
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { "TelescopePrompt", "NvimTree", "lazy" },
      color = {
        suggestion_color = colors.comment, -- Gris tenue para sugerencias
        cterm = 244,
      },
      log_level = "info",
      disable_inline_completion = false,
      disable_keymaps = false,
    })
  end,
}
