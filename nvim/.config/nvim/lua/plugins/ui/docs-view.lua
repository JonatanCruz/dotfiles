-- ============================================================================
-- NVIM-DOCS-VIEW
-- ============================================================================
-- Muestra la documentación LSP en un panel lateral persistente

return {
  "amrbashir/nvim-docs-view",
  cmd = { "DocsViewToggle", "DocsViewUpdate" },
  keys = {
    { "<leader>K", "<cmd>DocsViewToggle<cr>", desc = "Toggle Docs View" },
  },
  opts = {
    position = "right",
    width = 60,
    height = 10,
    update_mode = "auto",
  },
}
