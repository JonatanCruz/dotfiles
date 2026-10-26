-- ============================================================================
-- Nvim-notify - Notificaciones modernas
-- ============================================================================
-- Sistema de notificaciones elegante para Neovim.
-- Documentación: https://github.com/rcarriga/nvim-notify
-- ============================================================================

return {
  "rcarriga/nvim-notify",
  config = function()
    require("notify").setup({
      -- Con fondo transparente, notify mezcla el fade-out con este color.
      -- #1e1e2e = base de Catppuccin Mocha (con #000000 el fade iba a negro).
      background_colour = "#1e1e2e",
    })
    vim.notify = require("notify")
  end,
}
