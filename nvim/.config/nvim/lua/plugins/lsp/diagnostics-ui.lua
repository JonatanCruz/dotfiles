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

  -- lsp_lines: Muestra diagnósticos como líneas virtuales (alternativa a virtual_text)
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    keys = {
      {
        "<leader>ul",
        function()
          require("lsp_lines").toggle()
        end,
        desc = "Toggle LSP Lines",
      },
    },
    config = function()
      require("lsp_lines").setup()

      -- Desactivar por defecto, usar solo cuando sea necesario
      vim.diagnostic.config({
        virtual_text = true,
        virtual_lines = false,
      })
    end,
  },

  -- tiny-inline-diagnostic: Diagnósticos inline minimalistas
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
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
