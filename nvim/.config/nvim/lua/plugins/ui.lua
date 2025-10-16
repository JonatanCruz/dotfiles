return {
  -- Lualine (la barra de estado que ya tenías)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'catppuccin',
      },
    },
  },

  -- Nvim-tree: El explorador de archivos
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Para los iconos
    config = function()
      require('nvim-tree').setup({
        -- Opciones de configuración si las necesitas
        actions = {
          open_file = {
            -- Cierra NvimTree automáticamente después de abrir un archivo
            quit_on_open = true,
          },
        },
      })

      -- Hacemos que el fondo de NvimTree y sus ventanas flotantes sean transparentes
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NvimTreeNormalFloat", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "none" })

      local keymap = vim.keymap.set
      keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Alternar explorador de archivos' })
    end
  },

  -- Which-key: Mostrar keybindings disponibles
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        marks = true,     -- Mostrar marks con m
        registers = true, -- Mostrar registros con "
        spelling = {
          enabled = true,  -- z= para sugerencias de spelling
          suggestions = 20,
        },
        presets = {
          operators = true,    -- Ayuda con operadores como d, y, c
          motions = true,      -- Ayuda con motions
          text_objects = true, -- Ayuda con text objects como iw, i(
          windows = true,      -- Ayuda con comandos de ventanas
          nav = true,          -- Navegación miscelánea
          z = true,            -- Bindings que empiezan con z
          g = true,            -- Bindings que empiezan con g
        },
      },
      win = {
        border = 'rounded',
        padding = { 2, 2, 2, 2 },
      },
      -- Ordenar alfabéticamente
      sort_by_description = false,
      -- Mostrar íconos
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)

      -- Transparencia para which-key (debe ir después de setup)
      vim.api.nvim_set_hl(0, 'WhichKeyFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'WhichKeyBorder', { fg = '#89b4fa', bg = 'none' }) -- Azul Catppuccin

      -- Registrar grupos de keybindings con descripciones (ordenados alfabéticamente)
      -- Sintaxis actualizada para which-key v3
      wk.add({
        { '<leader>b', group = 'Buffer' },
        { '<leader>f', group = 'Buscar (Telescope)' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Git Hunk' },
        { '<leader>l', group = 'Linting' },
        { '<leader>n', group = 'No-highlight' },
        { '<leader>p', group = 'Paquetes (Lazy/Mason)' },
        { '<leader>r', group = 'Reload/Rename' },
        { '<leader>s', group = 'Splits' },
        { '<leader>t', group = 'Toggle/Terminal' },
        { '<leader>x', group = 'Trouble/Diagnósticos' },
      })
    end,
  },

  -- Nvim-notify: Notificaciones modernas
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        background_colour = '#000000', -- Fondo semi-transparente
      })
      vim.notify = require('notify')   -- Reemplaza la función `print` de vim
    end
  }
}
