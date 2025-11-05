-- ===================================================================
-- nvim-dap-ui: Interfaz gráfica para Debug Adapter Protocol
-- ===================================================================
-- UI moderna y visual para debugging con layouts optimizados
-- Se integra automáticamente con nvim-dap

return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      -- Toggle DAP UI
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "🎨 Toggle DAP UI",
      },
      -- Eval en modo visual
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = "v",
        desc = "🔍 Eval Selection",
      },
      -- Float eval
      {
        "<leader>df",
        function()
          require("dapui").float_element()
        end,
        desc = "📦 Float Element",
      },
    },
    opts = {
      -- ===============================================================
      -- ICONOS (DRACULA THEME)
      -- ===============================================================
      icons = {
        expanded = "▾",
        collapsed = "▸",
        current_frame = "▸",
      },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⬇",
          step_over = "⬆",
          step_out = "⬅",
          step_back = "↶",
          run_last = "↻",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },

      -- ===============================================================
      -- VENTANAS Y ELEMENTOS
      -- ===============================================================
      element_mappings = {}, -- Keymaps personalizados dentro de elementos UI

      expand_lines = true, -- Expandir líneas por defecto

      floating = {
        max_height = 0.9, -- 90% de altura de pantalla
        max_width = 0.9, -- 90% de ancho de pantalla
        border = "rounded", -- Border style: "single" | "double" | "rounded" | "solid" | "shadow"
        mappings = {
          close = { "q", "<Esc>" },
        },
      },

      force_buffers = true, -- Forzar buffers para ventanas de DAP UI

      -- ===============================================================
      -- LAYOUTS
      -- ===============================================================
      layouts = {
        -- Layout 1: Panel izquierdo con scopes, breakpoints, stacks, watches
        {
          elements = {
            -- Variables locales y globales
            {
              id = "scopes",
              size = 0.35, -- 35% del espacio
            },
            -- Breakpoints
            {
              id = "breakpoints",
              size = 0.20, -- 20% del espacio
            },
            -- Stack de llamadas
            {
              id = "stacks",
              size = 0.25, -- 25% del espacio
            },
            -- Watches (expresiones observadas)
            {
              id = "watches",
              size = 0.20, -- 20% del espacio
            },
          },
          position = "left",
          size = 50, -- 50 columnas de ancho
        },
        -- Layout 2: Panel inferior con REPL y console
        {
          elements = {
            -- REPL para ejecutar comandos
            {
              id = "repl",
              size = 0.5, -- 50% del espacio
            },
            -- Console para logs
            {
              id = "console",
              size = 0.5, -- 50% del espacio
            },
          },
          position = "bottom",
          size = 12, -- 12 líneas de altura
        },
      },

      -- ===============================================================
      -- CONFIGURACIÓN DE VENTANAS FLOTANTES POR ELEMENTO
      -- ===============================================================
      floating_windows = {
        scopes = {
          border = "rounded",
          max_width = 0.8,
          max_height = 0.8,
        },
        repl = {
          border = "rounded",
          max_width = 0.8,
          max_height = 0.8,
        },
      },

      -- ===============================================================
      -- MAPPINGS DENTRO DE UI
      -- ===============================================================
      mappings = {
        -- Use una lógica normal de buffer
        edit = "e",
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        repl = "r",
        toggle = "t",
      },

      -- ===============================================================
      -- RENDER
      -- ===============================================================
      render = {
        indent = 1,
        max_value_lines = 100, -- Máximo de líneas para valores grandes
      },
    },

    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")

      -- Aplicar configuración
      dapui.setup(opts)

      -- ===============================================================
      -- AUTO-ABRIR/CERRAR DAP UI
      -- ===============================================================

      -- Abrir DAP UI automáticamente al iniciar debugging
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      -- Cerrar DAP UI automáticamente al terminar debugging
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- ===============================================================
      -- HIGHLIGHT GROUPS (DRACULA THEME)
      -- ===============================================================
      -- Colores consistentes con el tema Dracula

      -- Elementos expandidos/colapsados
      vim.api.nvim_set_hl(0, "DapUIScope", { fg = "#bd93f9" }) -- Dracula purple
      vim.api.nvim_set_hl(0, "DapUIType", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIDecoration", { fg = "#6272a4" }) -- Dracula comment
      vim.api.nvim_set_hl(0, "DapUIThread", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIStoppedThread", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUISource", { fg = "#bd93f9" }) -- Dracula purple
      vim.api.nvim_set_hl(0, "DapUILineNumber", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIFloatBorder", { fg = "#6272a4" }) -- Dracula comment

      -- Valores y variables
      vim.api.nvim_set_hl(0, "DapUIVariable", { fg = "#f8f8f2" }) -- Dracula foreground
      vim.api.nvim_set_hl(0, "DapUIValue", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIModifiedValue", { fg = "#ffb86c", bold = true }) -- Dracula orange

      -- Frames y breakpoints
      vim.api.nvim_set_hl(0, "DapUIFrameName", { fg = "#f8f8f2" }) -- Dracula foreground
      vim.api.nvim_set_hl(0, "DapUIBreakpointsPath", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIBreakpointsInfo", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIBreakpointsCurrentLine", {
        fg = "#50fa7b",
        bold = true,
      }) -- Dracula green bold

      -- Watches
      vim.api.nvim_set_hl(0, "DapUIWatchesEmpty", { fg = "#6272a4" }) -- Dracula comment
      vim.api.nvim_set_hl(0, "DapUIWatchesValue", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIWatchesError", { fg = "#ff5555" }) -- Dracula red

      -- Controles
      vim.api.nvim_set_hl(0, "DapUIPlayPause", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIRestart", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapUIStop", { fg = "#ff5555" }) -- Dracula red
      vim.api.nvim_set_hl(0, "DapUIStepOver", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIStepInto", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIStepBack", { fg = "#8be9fd" }) -- Dracula cyan
      vim.api.nvim_set_hl(0, "DapUIStepOut", { fg = "#8be9fd" }) -- Dracula cyan

      -- ===============================================================
      -- KEYMAPS ADICIONALES EN BUFFERS DE DAP UI
      -- ===============================================================
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dapui_*",
        callback = function()
          -- Cerrar con 'q'
          vim.keymap.set("n", "q", function()
            dapui.close()
          end, { buffer = true, desc = "Close DAP UI" })

          -- Refresh con 'r'
          vim.keymap.set("n", "r", function()
            dapui.toggle()
            dapui.toggle()
          end, { buffer = true, desc = "Refresh DAP UI" })
        end,
      })

      -- ===============================================================
      -- NOTIFICACIÓN DE INICIALIZACIÓN
      -- ===============================================================
      local notify_available, notify = pcall(require, "notify")
      if notify_available then
        notify("DAP UI loaded successfully", "info", {
          title = "nvim-dap-ui",
          timeout = 2000,
        })
      end
    end,
  },
}
