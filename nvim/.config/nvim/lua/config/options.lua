-- Opciones de Neovim
local opt = vim.opt

opt.number = true          -- Muestra los números de línea
opt.relativenumber = true  -- Muestra los números de línea relativos
opt.mouse = 'a'            -- Habilita el uso del ratón
opt.wrap = false           -- Desactiva el ajuste de línea
opt.clipboard = 'unnamedplus' -- Usa el portapapeles del sistema

-- Indentación
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true

-- Apariencia
opt.termguicolors = true
opt.signcolumn = 'yes'
opt.cursorline = true
