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

      -- Aplicar transparencia completa usando la utilidad centralizada
      local transparency = require("utils.transparency")
      transparency.apply_transparency()

      -- Configuraciones adicionales de color específicas
      local colors = require("utils.colors")

      -- Separador igual al borde de Tmux (Catppuccin Overlay0)
      vim.api.nvim_set_hl(0, "VertSplit", { fg = colors.catppuccin.overlay0 })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.catppuccin.overlay0 })

      -- Selección en Pmenu con color pero visible
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.catppuccin.surface0, bold = true })

      -- Configurar autocomando para re-aplicar transparencia al cambiar theme
      transparency.setup_autocmd()
    end,
  },
}
