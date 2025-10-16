-- ============================================================================
-- LazyGit - Interfaz TUI para Git
-- ============================================================================
-- Cliente git con interfaz de terminal completa para operaciones git avanzadas.
-- Documentación: https://github.com/kdheepak/lazygit.nvim
-- ============================================================================

return {
  -- LazyGit: Interfaz TUI para git
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    keys = {
      { '<leader>gg', ':LazyGit<CR>', desc = 'Abrir LazyGit' }
    },
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
  }
}
