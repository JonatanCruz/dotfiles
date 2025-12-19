-- ============================================================================
-- DEBUG ADAPTER PROTOCOL (DAP)
-- ============================================================================
-- Debugging visual para múltiples lenguajes

return {
  -- DAP Core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI para DAP
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP UI" },
          { "<leader>de", function() require("dapui").eval() end, desc = "DAP Eval", mode = { "n", "v" } },
        },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
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
      -- Virtual text para variables
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      -- Mason integration
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          handlers = {},
          ensure_installed = {
            -- Agrega debuggers según tus necesidades:
            -- "js-debug-adapter",  -- JavaScript/TypeScript
            -- "python",            -- Python (debugpy)
            -- "codelldb",          -- C/C++/Rust
          },
        },
      },
    },
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condición: ")) end, desc = "Breakpoint condicional" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continuar" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Continuar con args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Ejecutar hasta cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Ir a línea (sin ejecutar)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Bajar en stack" },
      { "<leader>dk", function() require("dap").up() end, desc = "Subir en stack" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Ejecutar último" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pausar" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Sesión" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminar" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    config = function()
      -- Iconos para breakpoints
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
    end,
  },
}
