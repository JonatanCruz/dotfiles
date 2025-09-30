return {
  -- Lualine (la barra de estado que ya tenías)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'dracula',
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
