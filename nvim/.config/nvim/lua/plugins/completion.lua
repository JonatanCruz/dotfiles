return {
  -- Supermaven: Autocompletado AI (gratuito)
  {
    'supermaven-inc/supermaven-nvim',
    event = 'InsertEnter',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<Tab>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = { 'TelescopePrompt', 'NvimTree', 'lazy' },
        color = {
          suggestion_color = '#6c7086',  -- Overlay0 de Catppuccin Mocha
          cterm = 244,
        },
        log_level = 'info',
        disable_inline_completion = false,
        disable_keymaps = false,
      })
    end,
  },

  -- Motor de autocompletado
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets', -- Biblioteca de snippets precargados
      -- Fuentes de autocompletado
      'hrsh7th/cmp-nvim-lsp', -- para LSP
      'hrsh7th/cmp-buffer',   -- para el buffer actual
      'hrsh7th/cmp-path',     -- para rutas de archivos
      'hrsh7th/cmp-cmdline',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Cargar snippets de friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- Atajos de teclado para el menú de autocompletado
        -- Nota: Tab no se usa aquí para evitar conflicto con Supermaven
        -- Tab está reservado para aceptar sugerencias AI de Supermaven
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Aceptar sugerencia con Enter

          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
        }),
        -- Fuentes que usará nvim-cmp
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- Configuración para la línea de comandos (:)
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }    -- Sugerencias de rutas de archivos
        }, {
          { name = 'cmdline' } -- Sugerencias de comandos de nvim
        })
      })

      -- Configuración para la línea de búsqueda (/)
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' } -- Sugerencias del texto en el buffer actual
        }
      })
    end,
  },
}
