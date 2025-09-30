-- ============================================================================
-- OPCIONES DE NEOVIM
-- ============================================================================
-- Configuración general del comportamiento del editor

local opt = vim.opt

-- ============================================================================
-- INTERFAZ Y APARIENCIA
-- ============================================================================

opt.number = true                -- Muestra los números de línea
opt.relativenumber = true        -- Muestra los números de línea relativos
opt.cursorline = true            -- Resalta la línea actual
opt.signcolumn = 'yes'           -- Siempre muestra la columna de signos (para git, LSP, etc)
opt.wrap = false                 -- Desactiva el ajuste de línea
opt.scrolloff = 8                -- Mantiene 8 líneas visibles arriba/abajo del cursor
opt.sidescrolloff = 8            -- Mantiene 8 columnas visibles a los lados del cursor
opt.termguicolors = true         -- Habilita colores de 24 bits
opt.showmode = false             -- No mostrar modo (lo muestra lualine)
opt.conceallevel = 0             -- Muestra `` en archivos markdown
opt.cmdheight = 1                -- Altura de la línea de comandos
opt.pumheight = 10               -- Altura máxima del menú de autocompletado
opt.splitbelow = true            -- Split horizontal hacia abajo
opt.splitright = true            -- Split vertical hacia la derecha

-- ============================================================================
-- COMPORTAMIENTO DEL EDITOR
-- ============================================================================

opt.mouse = 'a'                  -- Habilita el uso del ratón
opt.clipboard = 'unnamedplus'    -- Usa el portapapeles del sistema
opt.undofile = true              -- Habilita el historial persistente de deshacer
opt.backup = false               -- No crear archivos de respaldo
opt.writebackup = false          -- No crear respaldo antes de sobrescribir
opt.swapfile = false             -- No crear archivos swap
opt.updatetime = 300             -- Tiempo de espera para escribir el swap (ms)
opt.timeoutlen = 400             -- Tiempo de espera para secuencias de teclas (ms)
opt.autoread = true              -- Recarga automática de archivos modificados externamente
opt.hidden = true                -- Permite cambiar de buffer sin guardar

-- ============================================================================
-- INDENTACIÓN Y FORMATO
-- ============================================================================

opt.tabstop = 2                  -- Número de espacios por Tab
opt.shiftwidth = 2               -- Número de espacios para auto-indentación
opt.expandtab = true             -- Convierte tabs en espacios
opt.autoindent = true            -- Copia la indentación de la línea anterior
opt.smartindent = true           -- Indentación inteligente en nuevas líneas
opt.breakindent = true           -- Mantiene la indentación en líneas envueltas

-- ============================================================================
-- BÚSQUEDA
-- ============================================================================

opt.ignorecase = true            -- Ignora mayúsculas/minúsculas al buscar
opt.smartcase = true             -- Distingue mayúsculas si la búsqueda las incluye
opt.hlsearch = true              -- Resalta las coincidencias de búsqueda
opt.incsearch = true             -- Búsqueda incremental

-- ============================================================================
-- RENDIMIENTO
-- ============================================================================

opt.lazyredraw = false           -- No redesibuja durante macros (puede causar problemas)
opt.synmaxcol = 240              -- Límite de columnas para resaltado de sintaxis

-- ============================================================================
-- AUTOCOMPLETADO
-- ============================================================================

opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Opciones de autocompletado
opt.shortmess:append 'c'         -- No mostrar mensajes de autocompletado en cmdline

-- ============================================================================
-- WILDCARDS Y ARCHIVOS IGNORADOS
-- ============================================================================

opt.wildmode = 'longest:full,full' -- Modo de autocompletado de comandos
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/build/*', '*/dist/*' }
