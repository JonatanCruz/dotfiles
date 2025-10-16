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
  },
  opts = {
    padding = true,
    sticky = true,
    ignore = "^$", -- Ignorar líneas vacías
  },
}
