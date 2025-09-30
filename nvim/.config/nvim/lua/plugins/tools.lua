return {
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- Opcional: dependencias si quieres una mejor integración con Telescope
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
        local keymap = vim.keymap.set
        keymap('n', '<leader>gg', ':LazyGit<CR>', { desc = 'Abrir LazyGit' })
    end
  }
}
