return {
  -- Trouble: UI mejorada para diagnósticos, quickfix, referencias
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',          desc = '󱖫 Diagnósticos workspace' },
      { '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = '󱖫 Diagnósticos documento' },
      { '<leader>xr', '<cmd>Trouble lsp_references toggle<cr>',      desc = ' Referencias LSP' },
      { '<leader>xs', '<cmd>Trouble lsp toggle<cr>',                 desc = ' Símbolos LSP' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',              desc = ' Quickfix' },
      { '<leader>xl', '<cmd>Trouble loclist toggle<cr>',             desc = ' Location list' },
      { 'gR',         '<cmd>Trouble lsp_references toggle<cr>',      desc = '󱖫 Referencias (Trouble)' },
    },
    opts = {},
    config = function(_, opts)
      require("trouble").setup(opts)
    end,
  },

  -- Mason: Gestor de LSPs, linters, formatters
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
    keys = {
      { "<leader>pm", "<cmd>Mason<cr>", desc = "Abrir Mason" },
    },
    config = function()
      require("mason").setup()
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = require("config.lsp_servers")

      -- Instalar servidores automáticamente con Mason
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })

      -- Aplicar capabilities globalmente a todos los servidores (patrón 0.11)
      vim.lsp.config("*", { capabilities = capabilities })

      -- Configuración específica para lua_ls
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- ================================================================
      -- KEYMAPS LSP - Se aplican a CUALQUIER LSP que se conecte al buffer
      -- Usando LspAttach es el patrón moderno (Neovim 0.10+) que funciona
      -- independientemente de cómo se inicialice el servidor.
      -- ================================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local opts = { noremap = true, silent = true, buffer = bufnr }
          local keymap = vim.keymap.set

          -- Navegación: ir a definición/declaración/implementación
          keymap("n", "gd", vim.lsp.buf.definition,    vim.tbl_extend("force", opts, { desc = "Ir a definición" }))
          keymap("n", "gD", vim.lsp.buf.declaration,   vim.tbl_extend("force", opts, { desc = "Ir a declaración" }))
          keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Ir a implementación" }))
          keymap("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Ir a definición de tipo" }))

          -- Referencias
          keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = " Referencias" }))
          keymap("n", "gR", "<cmd>Trouble lsp_references toggle<cr>", vim.tbl_extend("force", opts, { desc = "󱖫 Referencias (Trouble)" }))

          -- Documentación
          keymap("n", "K",  vim.lsp.buf.hover,          vim.tbl_extend("force", opts, { desc = " Documentación" }))
          keymap("n", "gK", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = " Firma de función" }))

          -- Código / LSP (<leader>c)
          keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { desc = " Code actions" }))
          keymap("n", "<leader>cr", vim.lsp.buf.rename,
            vim.tbl_extend("force", opts, { desc = "󰏫 Renombrar símbolo" }))
          keymap("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end,
            vim.tbl_extend("force", opts, { desc = " Formatear archivo" }))
          keymap("n", "<leader>ci", vim.lsp.buf.implementation,
            vim.tbl_extend("force", opts, { desc = " Ver implementaciones" }))
          keymap("n", "<leader>cd", vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "󰙅 Diagnóstico flotante" }))
          keymap("n", "<leader>cD", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            vim.tbl_extend("force", opts, { desc = "󱖫 Diagnósticos documento" }))
          keymap("n", "<leader>cs", "<cmd>Trouble lsp toggle<cr>",
            vim.tbl_extend("force", opts, { desc = " Símbolos LSP" }))

          -- Diagnósticos navegación
          keymap("n", "gl", vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "󰙅 Diagnóstico inline" }))
          keymap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,
            vim.tbl_extend("force", opts, { desc = "󰒮 Diagnóstico anterior" }))
          keymap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,
            vim.tbl_extend("force", opts, { desc = "󰒭 Diagnóstico siguiente" }))
          keymap("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
            vim.tbl_extend("force", opts, { desc = "󰒮 Error anterior" }))
          keymap("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
            vim.tbl_extend("force", opts, { desc = "󰒭 Error siguiente" }))
        end,
      })
    end,
  },
}
