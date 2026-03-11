return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Telescope' },  -- Cargar cuando se ejecute el comando :Telescope
    keys = {
      { '<leader>ff', desc = ' Archivos' },
      { '<leader>fg', desc = '󰍉 Buscar texto' },
      { '<leader>fb', desc = '󰓩 Buffers' },
      { '<leader>fr', desc = '󰋚 Recientes' },
      { '<leader>fw', desc = '󰍉 Palabra' },
      { '<leader>fh', desc = ' Ayuda' },
      { '<leader>fk', desc = '󰌌 Keymaps' },
      { '<leader>fc', desc = '󰘳 Comandos' },
      { '<leader>fm', desc = '󰉀 Marks' },
      { '<leader>fd', desc = '󰙅 Diagnósticos' },
      { '<leader>fo', desc = ' Símbolos' },
      { '<leader>fO', desc = ' Símbolos WS' },
      { '<leader>gf', desc = ' Archivos Git' },
      { '<leader>gl', desc = '󰊢 Log' },
      { '<leader>gs', desc = ' Status' },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          -- Buscar desde el directorio actual de Neovim (no todo el sistema)
          cwd = vim.fn.getcwd(),

          -- Configuración de archivos a ignorar/mostrar
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.svg",
            "%.otf",
            "%.ttf",
          },

          -- Respeta .gitignore pero busca en ocultos
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",              -- Buscar en archivos ocultos
            "--glob=!.git/",         -- Excepto .git
          },

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
        },
        pickers = {
          find_files = {
            hidden = true,           -- Mostrar archivos ocultos
            find_command = {
              "rg",
              "--files",
              "--hidden",            -- Buscar archivos ocultos
              "--glob=!.git/",       -- Excepto .git
            },
          },
        },
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

      -- Búsquedas principales
      keymap('n', '<leader>ff', builtin.find_files,  { desc = ' Archivos' })
      keymap('n', '<leader>fg', builtin.live_grep,   { desc = '󰍉 Buscar texto' })
      keymap('n', '<leader>fb', builtin.buffers,     { desc = '󰓩 Buffers' })
      keymap('n', '<leader>fr', builtin.oldfiles,    { desc = '󰋚 Archivos recientes' })
      keymap('n', '<leader>fw', builtin.grep_string, { desc = '󰍉 Palabra bajo cursor' })

      -- Neovim
      keymap('n', '<leader>fh', builtin.help_tags,   { desc = ' Ayuda Neovim' })
      keymap('n', '<leader>fk', builtin.keymaps,     { desc = '󰌌 Keymaps' })
      keymap('n', '<leader>fc', builtin.commands,    { desc = '󰘳 Comandos' })
      keymap('n', '<leader>fm', builtin.marks,       { desc = '󰉀 Marks' })

      -- Git
      keymap('n', '<leader>gf', builtin.git_files,   { desc = ' Archivos Git' })
      keymap('n', '<leader>gl', builtin.git_commits, { desc = '󰊢 Log commits' })
      keymap('n', '<leader>gs', builtin.git_status,  { desc = ' Git status' })

      -- LSP
      keymap('n', '<leader>fd', builtin.diagnostics, { desc = '󰙅 Diagnósticos' })
      keymap('n', '<leader>fo', builtin.lsp_document_symbols,  { desc = ' Símbolos documento' })
      keymap('n', '<leader>fO', builtin.lsp_workspace_symbols, { desc = ' Símbolos workspace' })
    end
  }
}
