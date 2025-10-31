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
    -- Navegación con Tab
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Siguiente buffer (Tab)" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior (Shift+Tab)" },

    -- Gestión intuitiva con <leader>b
    { "<leader>bc", "<cmd>bdelete<cr>", desc = "Cerrar buffer actual (close)" },
    { "<leader>bC", "<cmd>bdelete!<cr>", desc = "Forzar cierre de buffer" },
    { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Elegir buffer interactivo (pick)" },
    { "<leader>bx", "<cmd>BufferLinePickClose<cr>", desc = "Elegir buffer para cerrar" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Cerrar todos excepto actual (only)" },
    { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Cerrar buffers a la izquierda" },
    { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Cerrar buffers a la derecha" },

    -- Reordenar buffers
    { "<leader>b>", "<cmd>BufferLineMoveNext<cr>", desc = "Mover buffer a la derecha" },
    { "<leader>b<", "<cmd>BufferLineMovePrev<cr>", desc = "Mover buffer a la izquierda" },

    -- Ir a buffer por posición (1-9)
    { "<leader>b1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Ir al buffer 1" },
    { "<leader>b2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Ir al buffer 2" },
    { "<leader>b3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Ir al buffer 3" },
    { "<leader>b4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Ir al buffer 4" },
    { "<leader>b5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Ir al buffer 5" },
    { "<leader>b6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Ir al buffer 6" },
    { "<leader>b7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Ir al buffer 7" },
    { "<leader>b8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Ir al buffer 8" },
    { "<leader>b9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Ir al buffer 9" },
    { "<leader>b$", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Ir al último buffer" },
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
