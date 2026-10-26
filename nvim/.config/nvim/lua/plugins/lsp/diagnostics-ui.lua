-- ============================================================================
-- Plugins para Mejorar UI de Diagnósticos
-- ============================================================================
-- Visualización mejorada de errores, warnings y code actions
-- ============================================================================

return {
  -- nvim-lightbulb: Muestra icono cuando hay code actions disponibles
  {
    "kosayoda/nvim-lightbulb",
    event = { "CursorHold", "CursorHoldI" },
    opts = {
      sign = {
        enabled = true,
        text = "💡",
        hl = "DiagnosticSignWarn",
      },
      virtual_text = {
        enabled = false, -- Desactivado para no saturar
      },
      float = {
        enabled = false,
      },
      status_text = {
        enabled = false,
      },
      autocmd = {
        enabled = true,
        updatetime = 200, -- Actualizar cada 200ms
        events = { "CursorHold", "CursorHoldI" },
        pattern = { "*" },
      },
    },
    config = function(_, opts)
      require("nvim-lightbulb").setup(opts)
    end,
  },

  -- tiny-inline-diagnostic: Diagnósticos inline minimalistas
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    keys = {
      {
        -- Líneas virtuales nativas (nvim 0.11+), en lugar del plugin lsp_lines.
        -- uL y no ul: <leader>ul ya es `set list` en config/keymaps.lua
        "<leader>uL",
        function()
          local on = not vim.diagnostic.config().virtual_lines
          vim.diagnostic.config({ virtual_lines = on })
          vim.notify("Líneas virtuales de diagnóstico: " .. (on and "ON" or "OFF"))
        end,
        desc = "Toggle LSP Lines",
      },
    },
    config = function()
      -- Apagadas por defecto: tiny-inline-diagnostic ya pinta el virtual text,
      -- y las líneas virtuales solo se encienden con <leader>uL.
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
      })

      require('tiny-inline-diagnostic').setup({
        signs = {
          left = "",
          right = "",
          diag = "●",
          arrow = "    ",
          up_arrow = "    ",
          vertical = " │",
          vertical_end = " └",
        },
        hi = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "None",
        },
        blend = {
          factor = 0.27,
        },
        options = {
          show_source = false,
          throttle = 20,
          softwrap = 15,
          multiple_diag_under_cursor = false,
          multilines = false,
          show_all_diags_on_cursorline = false,
          enable_on_insert = false,
        },
      })
    end,
  },
}
