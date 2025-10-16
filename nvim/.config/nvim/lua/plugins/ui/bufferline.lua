-- ============================================================================
-- Bufferline - Pestañas de buffers en la parte superior
-- ============================================================================
-- Muestra los buffers abiertos como pestañas con integración de Catppuccin.
-- Documentación: https://github.com/akinsho/bufferline.nvim
--
-- NOTA: La transparencia del fondo puede requerir configuración adicional.
-- Para intentar transparencia en el futuro, ver:
--   - Opción 1: Deshabilitar integración de Catppuccin (bufferline = false)
--   - Opción 2: Usar highlights.fill = { bg = "" } o custom_highlights
--   - Opción 3: Autocomando post-setup para forzar bg = "NONE"
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
  opts = function()
    local colors = require("catppuccin.palettes").get_palette()

    return {
      options = {
        mode = "buffers",
        separator_style = { "│", "│" },  -- Separador vertical para estilo rectangular
        indicator = {
          style = "none",  -- Sin indicador adicional
        },
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
      highlights = {
        separator = {
          fg = colors.overlay0,
        },
        separator_selected = {
          fg = colors.overlay0,
        },
        separator_visible = {
          fg = colors.overlay0,
        },
      },
    }
  end,
}
