-- ============================================================================
-- Comment - Comentar código fácilmente
-- ============================================================================
-- Comenta/descomenta código con `gcc` (línea) o `gc` (modo visual).
-- Documentación: https://github.com/numToStr/Comment.nvim
-- ============================================================================

return {
  "numToStr/Comment.nvim",
  keys = {
    { "gcc", mode = "n", desc = "Comentar línea" },
    { "gc", mode = "v", desc = "Comentar selección" },
    { "gbc", mode = "n", desc = "Comentar bloque" },
    { "gb", mode = "v", desc = "Comentar bloque selección" },
    { "<leader>/", mode = "n", desc = "Comentar/descomentar línea" },
    { "<leader>/", mode = "v", desc = "Comentar/descomentar selección" },
  },
  config = function()
    require("Comment").setup({
      padding = true,
      sticky = true,
      ignore = "^$", -- Ignorar líneas vacías
      toggler = {
        line = "gcc",
        block = "gbc",
      },
      opleader = {
        line = "gc",
        block = "gb",
      },
      mappings = {
        basic = true,
        extra = true,
      },
    })

    -- Keybinding personalizado para <leader>/
    local api = require("Comment.api")
    vim.keymap.set("n", "<leader>/", api.toggle.linewise.current, { desc = "Comentar/descomentar línea" })
    vim.keymap.set("v", "<leader>/", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Comentar/descomentar selección" })
  end,
}
