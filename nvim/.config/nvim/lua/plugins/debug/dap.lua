-- ===================================================================
-- nvim-dap: Debug Adapter Protocol para Neovim
-- ===================================================================
-- Plugin principal de debugging con configuraciones para múltiples lenguajes
-- Lazy load: se activa con keybindings bajo <leader>d
--
-- FUSIÓN COMPLETA: debug/dap.lua + tools/dap.lua
-- Incluye: DAP Core, DAP UI, Virtual Text, Mason Integration
-- Lenguajes: Node.js, TypeScript, React, Python

return {
  -- Plugin principal de DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI visual para debugging
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          
          -- Auto-abrir/cerrar UI en eventos de debug
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },
      
      -- Virtual text para mostrar valores inline
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          virt_text_pos = "eol", -- Posición: 'eol' | 'overlay' | 'right_align'
        },
      },
      
      -- Mason integration para auto-instalación de adapters
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          handlers = {},
          ensure_installed = {
            "debugpy",           -- Python debugging
            "codelldb",          -- Rust/C/C++ debugging
            "js-debug-adapter",  -- JavaScript/TypeScript debugging
          },
        },
      },
      
      -- Dependencia requerida
      "nvim-neotest/nvim-nio",
    },
    
    keys = {
      -- ===============================================================
      -- BREAKPOINTS
      -- ===============================================================
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "🔴 Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "🟡 Conditional Breakpoint",
      },
      
      -- ===============================================================
      -- CONTROL DE EJECUCIÓN
      -- ===============================================================
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "▶️  Continue/Start",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "▶️  Continue with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "⏭️  Run to Cursor",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "🔁 Run Last",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "⏸️  Pause",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "⏹️  Terminate",
      },
      
      -- ===============================================================
      -- STEPPING
      -- ===============================================================
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "⬇️  Step Into",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "➡️  Step Over",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "⬆️  Step Out",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "🎯 Go to Line (no execute)",
      },
      
      -- ===============================================================
      -- STACK NAVIGATION
      -- ===============================================================
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "⬆️  Stack Up",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "⬇️  Stack Down",
      },
      
      -- ===============================================================
      -- UI & INSPECTION
      -- ===============================================================
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "🖥️  Toggle DAP UI",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "💬 Toggle REPL",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "🔍 Eval Expression",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "🔍 Hover Widgets",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "📋 Session Info",
      },
    },
    
    config = function()
      local dap = require("dap")

      -- ===============================================================
      -- CONFIGURACIÓN DE SIGNS (ICONOS)
      -- ===============================================================
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "❌",
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "▶️",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "📝",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })

      -- ===============================================================
      -- HIGHLIGHT GROUPS (DRACULA THEME)
      -- ===============================================================
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff5555" }) -- Dracula red
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f1fa8c" }) -- Dracula yellow
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#6272a4" }) -- Dracula comment
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#50fa7b" }) -- Dracula green
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#44475a" }) -- Dracula current line
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#8be9fd" }) -- Dracula cyan

      -- ===============================================================
      -- CONFIGURACIÓN DE ADAPTADORES
      -- ===============================================================

      -- Node.js / TypeScript (vscode-js-debug)
      -- El adaptador debe instalarse con Mason: npm install -g js-debug-adapter
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          -- Ruta al debug adapter (ajustar según instalación de Mason)
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      -- Python (debugpy)
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
      }

      -- ===============================================================
      -- CONFIGURACIONES DE DEBUG
      -- ===============================================================

      -- Node.js
      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "🟢 Launch Node.js",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "🔗 Attach to Node.js",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }

      -- TypeScript (usa la misma configuración que JavaScript)
      dap.configurations.typescript = dap.configurations.javascript

      -- TypeScript React (TSX)
      dap.configurations.typescriptreact = {
        {
          type = "pwa-node",
          request = "launch",
          name = "🟢 Launch Next.js/React",
          runtimeExecutable = "npm",
          runtimeArgs = { "run", "dev" },
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
      }

      -- JavaScript React (JSX)
      dap.configurations.javascriptreact = dap.configurations.typescriptreact

      -- Python
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "🐍 Launch Python File",
          program = "${file}",
          pythonPath = function()
            return "python3"
          end,
        },
      }

      -- ===============================================================
      -- AUTOCOMANDOS Y LISTENERS
      -- ===============================================================

      -- Notificaciones con nvim-notify (si está disponible)
      local notify_available, notify = pcall(require, "notify")

      dap.listeners.before.attach["dap_notify"] = function()
        if notify_available then
          notify("Debugger attached", "info", { title = "DAP" })
        end
      end

      dap.listeners.before.launch["dap_notify"] = function()
        if notify_available then
          notify("Debugger launched", "info", { title = "DAP" })
        end
      end

      dap.listeners.before.event_terminated["dap_notify"] = function()
        if notify_available then
          notify("Debugger terminated", "warn", { title = "DAP" })
        end
      end

      dap.listeners.before.event_exited["dap_notify"] = function()
        if notify_available then
          notify("Debugger exited", "warn", { title = "DAP" })
        end
      end
    end,
  },
}
