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
      background_colour = "#000000",
    })
    vim.notify = require("notify")
  end,
}
