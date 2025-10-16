-- ============================================================================
-- Bufferline - Pestañas de buffers en la parte superior
-- ============================================================================
-- Muestra los buffers abiertos como pestañas con integración de Catppuccin.
-- Documentación: https://github.com/akinsho/bufferline.nvim
-- ============================================================================

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
  event = "VeryLazy",
  keys = {
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Siguiente buffer" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Elegir buffer" },
    { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Cerrar buffer (elegir)" },
  },
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slant",
      always_show_bufferline = false,
      show_buffer_close_icons = true,
      show_close_icon = false,
      color_icons = true,
      diagnostics = "nvim_lsp",
      offsets = {
        {
          filetype = "NvimTree",
          text = "Explorador de Archivos",
          text_align = "center",
          separator = true,
        },
      },
    },
  },
}
