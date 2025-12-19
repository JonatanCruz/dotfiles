-- ============================================================================
-- GOTO PREVIEW
-- ============================================================================
-- Preview de definiciones, referencias e implementaciones en ventanas flotantes

return {
  "rmagatti/goto-preview",
  event = "LspAttach",
  keys = {
    { "gpd", function() require("goto-preview").goto_preview_definition() end, desc = "Preview definición" },
    { "gpt", function() require("goto-preview").goto_preview_type_definition() end, desc = "Preview tipo" },
    { "gpi", function() require("goto-preview").goto_preview_implementation() end, desc = "Preview implementación" },
    { "gpD", function() require("goto-preview").goto_preview_declaration() end, desc = "Preview declaración" },
    { "gpr", function() require("goto-preview").goto_preview_references() end, desc = "Preview referencias" },
    { "gP", function() require("goto-preview").close_all_win() end, desc = "Cerrar previews" },
  },
  opts = {
    width = 120,
    height = 25,
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    default_mappings = false,
    debug = false,
    opacity = nil,
    resizing_mappings = false,
    post_open_hook = nil,
    post_close_hook = nil,
    references = {
      telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
    },
    focus_on_open = true,
    dismiss_on_move = false,
    force_close = true,
    bufhidden = "wipe",
    stack_floating_preview_windows = true,
    preview_window_title = { enable = true, position = "left" },
  },
}
