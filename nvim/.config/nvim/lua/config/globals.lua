-- ============================================================================
-- CONFIGURACIÓN GLOBAL DE NEOVIM
-- ============================================================================
-- Variables globales y configuraciones que deben cargarse antes que todo

-- ============================================================================
-- VARIABLES GLOBALES
-- ============================================================================

-- Leader keys (ya configurados en init.lua pero documentados aquí)
-- vim.g.mapleader = ' '
-- vim.g.maplocalleader = ' '

-- ============================================================================
-- CONFIGURACIONES DE PLUGINS
-- ============================================================================

-- Deshabilitar plugins por defecto de Neovim que no usamos
vim.g.loaded_netrw = 1       -- Deshabilitar netrw (usamos nvim-tree)
vim.g.loaded_netrwPlugin = 1

-- ============================================================================
-- CONFIGURACIONES DE PROVIDERS
-- ============================================================================
-- Deshabilitar providers que no necesitas para mejorar el tiempo de carga

-- Si no usas Ruby
vim.g.loaded_ruby_provider = 0

-- Si no usas Perl
vim.g.loaded_perl_provider = 0

-- Si no usas Node.js (comentar si usas plugins que requieren Node)
-- vim.g.loaded_node_provider = 0

-- Si no usas Python (comentar si usas plugins que requieren Python)
-- vim.g.loaded_python3_provider = 0

-- ============================================================================
-- CONFIGURACIONES ADICIONALES
-- ============================================================================

-- Configurar el shell (útil para comandos de terminal dentro de Neovim)
if vim.fn.executable('zsh') == 1 then
  vim.o.shell = 'zsh'
end
