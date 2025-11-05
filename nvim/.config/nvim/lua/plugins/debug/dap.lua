-- ===================================================================
-- nvim-dap: Debug Adapter Protocol para Neovim
-- ===================================================================
-- Plugin principal de debugging con configuraciones para Node.js/TS
-- Lazy load: se activa con keybindings bajo <leader>d

return {
  -- Plugin principal de DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
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
      -- Dependencia requerida
      "nvim-neotest/nvim-nio",
    },
    keys = {
      -- Toggle breakpoint
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "🔴 Toggle Breakpoint",
      },
      -- Breakpoint condicional
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "🟡 Conditional Breakpoint",
      },
      -- Continue/Start
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "▶️  Continue/Start",
      },
      -- Step into
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "⬇️  Step Into",
      },
      -- Step over
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "➡️  Step Over",
      },
      -- Step out
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "⬆️  Step Out",
      },
      -- Terminate
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "⏹️  Terminate",
      },
      -- REPL
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "💬 Toggle REPL",
      },
      -- Evaluate expression
      {
        "<leader>de",
        function()
          require("dap.ui.widgets").hover()
        end,
        mode = { "n", "v" },
        desc = "🔍 Eval Expression",
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

      -- ===============================================================
      -- AUTOCOMANDOS
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
