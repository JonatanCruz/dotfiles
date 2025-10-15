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
    -- El keybinding se define aquí para que lazy.nvim lo registre inmediatamente
    keys = {
      { '<leader>gg', ':LazyGit<CR>', desc = 'Abrir LazyGit' }
    },
    -- Opcional: dependencias si quieres una mejor integración con Telescope
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
  }
}
