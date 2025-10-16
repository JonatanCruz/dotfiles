return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      -- Carga la configuración del tema con la opción de transparencia
      require('catppuccin').setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          telescope = {
            enabled = true,
          },
          lsp_trouble = true,
          which_key = true,
          alpha = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
        },
      })

      vim.cmd.colorscheme 'catppuccin'

      -- Iguala el color del separador de Neovim con el del borde de Tmux (Catppuccin Overlay0)
      vim.api.nvim_set_hl(0, 'VertSplit', { fg = '#6c7086' })
      -- Asegura que las ventanas flotantes (como las de Telescope) también sean transparentes
      vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
      -- Hacemos que la línea del cursor no tenga fondo, solo subrayado
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" }) -- Para el número de línea también
      -- Transparencia para el menú contextual (click derecho)
      vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })    -- Fondo del menú
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#313244" })  -- Fondo de la selección (Surface0)
    end,
  },
}
