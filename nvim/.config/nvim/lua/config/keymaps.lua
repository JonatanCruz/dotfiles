-- ============================================================================
-- KEYMAPS GLOBALES
-- ============================================================================
-- Atajos de teclado que no dependen de ningún plugin específico
-- Los keymaps específicos de plugins están en sus respectivos archivos

local keymap = vim.keymap.set

-- ============================================================================
-- GESTIÓN DE ARCHIVOS Y BUFFERS
-- ============================================================================

keymap('n', '<leader>w', ':w<CR>', { desc = 'Guardar archivo' })
keymap('n', '<leader>q', ':q<CR>', { desc = 'Cerrar ventana' })
keymap('n', '<leader>Q', ':qa!<CR>', { desc = 'Salir sin guardar' })
keymap('n', '<leader>x', ':x<CR>', { desc = 'Guardar y salir' })

-- Navegación entre buffers
keymap('n', '<S-l>', ':bnext<CR>', { desc = 'Siguiente buffer' })
keymap('n', '<S-h>', ':bprevious<CR>', { desc = 'Buffer anterior' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Cerrar buffer actual' })

-- ============================================================================
-- NAVEGACIÓN ENTRE VENTANAS (SPLITS)
-- ============================================================================
-- Nota: Estos serán sobrescritos por tmux-navigator si está activo

keymap('n', '<C-h>', '<C-w>h', { desc = 'Mover a la ventana izquierda' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Mover a la ventana de abajo' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Mover a la ventana de arriba' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Mover a la ventana derecha' })

-- Redimensionar ventanas
keymap('n', '<C-Up>', ':resize +2<CR>', { desc = 'Aumentar altura' })
keymap('n', '<C-Down>', ':resize -2<CR>', { desc = 'Disminuir altura' })
keymap('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Disminuir ancho' })
keymap('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Aumentar ancho' })

-- Crear splits
keymap('n', '<leader>sv', '<C-w>v', { desc = 'Split vertical' })
keymap('n', '<leader>sh', '<C-w>s', { desc = 'Split horizontal' })
keymap('n', '<leader>se', '<C-w>=', { desc = 'Igualar tamaño de splits' })
keymap('n', '<leader>sx', ':close<CR>', { desc = 'Cerrar split actual' })

-- ============================================================================
-- EDICIÓN MEJORADA
-- ============================================================================

-- Mover líneas seleccionadas arriba/abajo en modo visual
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Mover línea abajo' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Mover línea arriba' })

-- Mantener el cursor centrado al hacer scroll
keymap('n', '<C-d>', '<C-d>zz', { desc = 'Media página abajo (centrado)' })
keymap('n', '<C-u>', '<C-u>zz', { desc = 'Media página arriba (centrado)' })

-- Mantener el cursor centrado al buscar
keymap('n', 'n', 'nzzzv', { desc = 'Siguiente búsqueda (centrado)' })
keymap('n', 'N', 'Nzzzv', { desc = 'Búsqueda anterior (centrado)' })

-- Pegar sin perder el contenido del registro
keymap('x', '<leader>p', '"_dP', { desc = 'Pegar sin perder registro' })

-- Indentar en modo visual sin perder la selección
keymap('v', '<', '<gv', { desc = 'Indentar izquierda' })
keymap('v', '>', '>gv', { desc = 'Indentar derecha' })

-- ============================================================================
-- UTILIDADES
-- ============================================================================

-- Desactivar el resaltado de búsqueda
keymap('n', '<leader>nh', ':nohl<CR>', { desc = 'Desactivar resaltado de búsqueda' })

-- Abrir terminal integrado
keymap('n', '<leader>tt', ':terminal<CR>', { desc = 'Abrir terminal' })

-- Recargar configuración de Neovim
keymap('n', '<leader>rr', ':source $MYVIMRC<CR>', { desc = 'Recargar configuración' })

-- Incrementar/decrementar números
keymap('n', '<leader>+', '<C-a>', { desc = 'Incrementar número' })
keymap('n', '<leader>-', '<C-x>', { desc = 'Decrementar número' })
