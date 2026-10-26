-- ============================================================================
-- vim-tmux-navigator - <C-h/j/k/l> entre splits de nvim y paneles de tmux
-- ============================================================================
-- Mitad nvim del par: la mitad tmux es el plugin homónimo en tmux/.tmux.conf,
-- que reenvía <C-h/j/k/l> a nvim cuando el panel activo lo ejecuta. Si nvim
-- está en el borde, el plugin le devuelve el movimiento a tmux.
-- Documentación: https://github.com/christoomey/vim-tmux-navigator
--
-- Carga diferida por `keys`/`cmd`: el plugin no hace nada hasta la primera
-- pulsación. Fuera de tmux se comporta como <C-w>h/j/k/l.
-- ============================================================================

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  init = function()
    -- Los mapeos los define lazy en `keys`; sin esto el plugin crearía los
    -- suyos (incluido <C-\>) al cargarse.
    vim.g.tmux_navigator_no_mappings = 1
  end,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Ventana/panel ←" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Ventana/panel ↓" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Ventana/panel ↑" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Ventana/panel →" },
  },
}
