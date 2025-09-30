-- Atajos de teclado que no dependen de ningún plugin específico
local keymap = vim.keymap.set

keymap('n', '<leader>w', ':w<CR>', { desc = 'Guardar archivo' })
keymap('n', '<leader>q', ':q<CR>', { desc = 'Cerrar ventana' })

-- Navegación básica entre ventanas (splits)
-- Nota: Estos serán sobrescritos por la lógica de tmux-navigator si está activo
keymap('n', '<C-h>', '<C-w>h', { desc = 'Mover a la ventana izquierda' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Mover a la ventana de abajo' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Mover a la ventana de arriba' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Mover a la ventana derecha' })
