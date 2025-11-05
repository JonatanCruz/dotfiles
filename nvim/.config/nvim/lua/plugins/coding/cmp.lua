-- ============================================================================
-- Nvim-cmp - Motor de autocompletado
-- ============================================================================
-- Sistema de autocompletado con soporte para LSP, snippets, buffer, path y cmdline.
-- Documentación: https://github.com/hrsh7th/nvim-cmp
-- ============================================================================

local constants = require("config.constants")

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Snippets
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    -- Fuentes de autocompletado
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Cargar snippets de friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Cargar custom snippets personalizados
    require("snippets").load()

    -- Configuración principal
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered({
          border = constants.borders.style,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = constants.borders.style,
        }),
      },
      -- Nota: La transparencia se gestiona globalmente en utils/transparency.lua
      -- Los grupos CmpNormal, CmpBorder, etc. se configuran automáticamente
      mapping = cmp.mapping.preset.insert({
        -- Scroll en documentación
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Trigger completion
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Cancelar
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirmar selección
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        -- Navegación (Tab reservado para Supermaven AI)
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = require("utils.icons").kind
          -- Iconos para kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. " " .. item.kind
          end

          -- Fuente del completado
          item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
          })[entry.source.name]

          return item
        end,
      },
      experimental = {
        ghost_text = false, -- Desactivado porque usamos Supermaven
      },
    })

    -- Configuración para la línea de comandos (:)
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({
        ["<Tab>"] = { c = cmp.mapping.select_next_item() },
        ["<S-Tab>"] = { c = cmp.mapping.select_prev_item() },
        ["<C-n>"] = { c = cmp.mapping.select_next_item() },
        ["<C-p>"] = { c = cmp.mapping.select_prev_item() },
      }),
      sources = cmp.config.sources({
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" },
            treat_trailing_slash = false,
          },
          keyword_length = 2,
        },
      }, {
        {
          name = "path",
          option = {
            trailing_slash = true,
            label_trailing_slash = true,
          },
        },
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
      completion = {
        completeopt = "menu,menuone,noselect",
      },
      experimental = {
        ghost_text = false,
      },
    })

    -- Configuración para la línea de búsqueda (/ y ?)
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline({
        ["<Tab>"] = { c = cmp.mapping.select_next_item() },
        ["<S-Tab>"] = { c = cmp.mapping.select_prev_item() },
        ["<C-n>"] = { c = cmp.mapping.select_next_item() },
        ["<C-p>"] = { c = cmp.mapping.select_prev_item() },
      }),
      sources = {
        { name = "buffer" },
      },
    })
  end,
}
