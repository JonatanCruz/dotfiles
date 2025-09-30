return {
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- Carga la configuración del tema con la opción de transparencia
      require('dracula').setup({
        transparent_bg = true,
        on_lualine = true,
      })

      vim.cmd.colorscheme 'dracula'

      -- Iguala el color del separador de Neovim con el del borde de Tmux
      vim.api.nvim_set_hl(0, 'VertSplit', { fg = '#6272a4' })
      -- Asegura que las ventanas flotantes (como las de Telescope) también sean transparentes
      vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
      -- Hacemos que la línea del cursor no tenga fondo, solo subrayado
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" }) -- Para el número de línea también
      -- Transparencia para el menú contextual (click derecho)
      vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })    -- Fondo del menú
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#44475a" })  -- Fondo de la selección
    end,
  },
}
