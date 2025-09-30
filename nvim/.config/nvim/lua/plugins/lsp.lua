return {
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
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = require("config.lsp_servers")

      -- Función on_attach (se ejecuta cuando el LSP se conecta a un buffer)
      local on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { noremap = true, silent = true, buffer = bufnr }

        keymap("n", "K", vim.lsp.buf.hover, opts)
        keymap("n", "gd", vim.lsp.buf.definition, opts)
        keymap("n", "gr", vim.lsp.buf.references, opts)
        keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
        keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
        keymap("n", "[d", vim.diagnostic.goto_prev, opts)
        keymap("n", "]d", vim.diagnostic.goto_next, opts)
      end

      -- Inicializa Mason
      mason.setup()

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
