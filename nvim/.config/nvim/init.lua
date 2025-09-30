-- Establece la variable global de líder ANTES de cargar cualquier otra cosa.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Carga la configuración de lazy.nvim, que se encargará del resto.
require('config.lazy')
