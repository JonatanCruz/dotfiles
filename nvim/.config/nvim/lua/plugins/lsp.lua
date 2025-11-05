return {
  -- Trouble: UI mejorada para diagnósticos, quickfix, referencias
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      position = 'bottom',
      height = 10,
      width = 50,
      icons = true,
      mode = 'workspace_diagnostics',
      fold_open = '',
      fold_closed = '',
      group = true,
      padding = true,
      action_keys = {
        close = 'q',
        cancel = '<esc>',
        refresh = 'r',
        jump = { '<cr>', '<tab>' },
        open_split = { '<c-x>' },
        open_vsplit = { '<c-v>' },
        open_tab = { '<c-t>' },
        jump_close = { 'o' },
        toggle_mode = 'm',
        toggle_preview = 'P',
        hover = 'K',
        preview = 'p',
        close_folds = { 'zM', 'zm' },
        open_folds = { 'zR', 'zr' },
        toggle_fold = { 'zA', 'za' },
        previous = 'k',
        next = 'j',
      },
      indent_lines = true,
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      auto_jump = { 'lsp_definitions' },
      signs = {
        error = '',
        warning = '',
        hint = '',
        information = '',
        other = '',
      },
      use_diagnostic_signs = false,
    },
    keys = {
      -- Diagnósticos con <leader>x (siguiendo convención de LazyVim/NvChad)
      { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble (diagnostics)' },
      { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Document Diagnostics' },
      { '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', desc = 'Quickfix List' },
      { '<leader>xl', '<cmd>TroubleToggle loclist<cr>', desc = 'Location List' },
      { '<leader>xr', '<cmd>TroubleToggle lsp_references<cr>', desc = 'LSP References' },
      { 'gR', '<cmd>TroubleToggle lsp_references<cr>', desc = 'LSP References (alias)' },
    },
    config = function(_, opts)
      require("trouble").setup(opts)
      -- La transparencia se gestiona globalmente en utils/transparency.lua
      -- TroubleNormal se configura automáticamente
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
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = require("config.lsp_servers")

      -- Función on_attach (se ejecuta cuando el LSP se conecta a un buffer)
      local on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { noremap = true, silent = true, buffer = bufnr }

        -- ================================================================
        -- NAVEGACIÓN LSP - Comandos que empiezan con 'g' (go to...)
        -- ================================================================

        -- Ir a definición/declaración
        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Ir a definición" }))
        keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Ir a declaración" }))

        -- Ver referencias y uso
        keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Ver referencias" }))
        keymap("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", vim.tbl_extend("force", opts, { desc = "Referencias en Trouble" }))

        -- Ir a implementación y type definition
        keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Ir a implementación" }))
        keymap("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Ir a definición de tipo" }))

        -- ================================================================
        -- INFORMACIÓN Y DOCUMENTACIÓN
        -- ================================================================

        -- Hover (documentación flotante)
        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Ver documentación" }))
        keymap("n", "gK", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Ver firma de función" }))

        -- ================================================================
        -- ACCIONES DE CÓDIGO
        -- ================================================================

        -- Code actions y refactoring
        keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
        keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Renombrar símbolo" }))
        keymap("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Formatear archivo" }))

        -- ================================================================
        -- DIAGNÓSTICOS (ERRORES Y WARNINGS)
        -- ================================================================
        -- NOTA: <leader>x ahora es prefijo para TODOS los diagnósticos (convención LazyVim)
        -- <leader>d se reserva para Debug (DAP)
        -- Ver también Trouble keybindings más arriba (<leader>xx, xw, xd, etc.)

        -- Ver diagnósticos flotantes
        keymap("n", "<leader>xe", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Ver diagnóstico (examine)" }))
        keymap("n", "gl", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Ver diagnóstico en línea" }))

        -- Navegar entre diagnósticos
        keymap("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Diagnóstico anterior" }))
        keymap("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Diagnóstico siguiente" }))
        keymap("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, vim.tbl_extend("force", opts, { desc = "Error anterior" }))
        keymap("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, vim.tbl_extend("force", opts, { desc = "Error siguiente" }))

        -- Lista de diagnósticos nativa
        keymap("n", "<leader>xL", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Location list nativa" }))
      end

      -- Mason ya está inicializado en su plugin separado arriba

      -- Esta es la parte corregida.
      -- La configuración de los handlers va DENTRO de la llamada a setup.
      mason_lspconfig.setup({
        -- Lista de servidores a instalar automáticamente
        ensure_installed = servers,

        -- Configuración de los manejadores (handlers)
        handlers = {
          -- El manejador por defecto. Se aplicará a todos los servidores
          -- que no tengan una configuración específica más abajo.
          function(server_name)
            lspconfig[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end,

          -- Configuración específica para el LSP de Lua
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" },
                  },
                },
              },
            })
          end,
        },
      })
    end,
  },
}
