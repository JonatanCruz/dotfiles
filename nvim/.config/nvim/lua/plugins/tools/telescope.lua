return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Telescope' },  -- Cargar cuando se ejecute el comando :Telescope
    keys = {
      { '<leader>ff', desc = 'Buscar archivos' },
      { '<leader>fg', desc = 'Buscar texto en proyecto' },
      { '<leader>fb', desc = 'Buscar en buffers abiertos' },
      { '<leader>fh', desc = 'Buscar en la ayuda de Nvim' },
      { '<leader>ft', desc = 'Buscar TODOs' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        -- Esta es la sección nueva y más importante
        defaults = {
          mappings = {
            -- Mapeos para el modo inserción (i)
            i = {
              -- Navegar en la lista de resultados
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,

              -- Navegar en el historial de búsquedas
              ['<C-n>'] = actions.cycle_history_next,
              ['<C-p>'] = actions.cycle_history_prev,
            },
            -- Mapeos para el modo normal (n)
            n = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            }
          }
        }
      })

      -- Transparencia (gestionada por utils/transparency.lua)
      -- Los highlights TelescopeNormal, TelescopeBorder, etc. se configuran automáticamente
      -- Solo configuramos la selección con un color específico
      local colors = require("utils.colors")
      vim.api.nvim_set_hl(0, "TelescopeSelection", {
        bg = colors.catppuccin.surface0,
        bold = true,
      })

      -- Atajos de teclado
      local builtin = require('telescope.builtin')
      local keymap = vim.keymap.set

      keymap('n', '<leader>ff', builtin.find_files, { desc = 'Buscar archivos' })
      keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Buscar texto en proyecto' })
      keymap('n', '<leader>fb', builtin.buffers, { desc = 'Buscar en buffers abiertos' })
      keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Buscar en la ayuda de Nvim' })
    end
  }
}
