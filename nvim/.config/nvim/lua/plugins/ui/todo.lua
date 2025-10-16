-- ============================================================================
-- Todo-comments - Resalta comentarios especiales
-- ============================================================================
-- Resalta comentarios como TODO, HACK, FIX, NOTE, WARN, PERF en el código.
-- Documentación: https://github.com/folke/todo-comments.nvim
-- ============================================================================

local icons = require("utils.icons")

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    signs = true,
    keywords = {
      FIX = { icon = icons.todo.FIX, color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = icons.todo.TODO, color = "info" },
      HACK = { icon = icons.todo.HACK, color = "warning" },
      WARN = { icon = icons.todo.WARN, color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = icons.todo.PERF, color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = icons.todo.NOTE, color = "hint", alt = { "INFO" } },
    },
  },
  keys = {
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Buscar TODOs" },
  },
}
