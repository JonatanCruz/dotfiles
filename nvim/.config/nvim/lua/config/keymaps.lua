-- ============================================================================
-- KEYMAPS GLOBALES
-- ============================================================================
-- Jerarquía de prefijos (convención LazyVim/comunidad):
--
--   Sin prefijo   → Navegación LSP (gd, gr, gi, K...)
--   [/]           → Navegación entre elementos (diagnósticos, hunks, tabs)
--   <leader>b     → Buffers
--   <leader>c     → Código / LSP actions
--   <leader>d     → Debug (DAP)
--   <leader>e     → Explorer (árbol de archivos)
--   <leader>f     → Find / Telescope
--   <leader>g     → Git
--   <leader>o     → Outline (Aerial)
--   <leader>p     → Packages (Lazy, Mason)
--   <leader>q     → Quit / Session
--   <leader>s     → Search / Replace
--   <leader>t     → Tests
--   <leader>u     → UI Toggles
--   <leader>w     → Windows / Splits
--   <leader>x     → Diagnósticos (Trouble + Quickfix)
--   <leader>z     → Zen / Focus
-- ============================================================================

local map = vim.keymap.set

-- ============================================================================
-- EDITOR CORE — Guardar / Salir
-- ============================================================================

map("n", "<leader>w",  "<cmd>w<cr>",   { desc = " Guardar archivo" })
map("n", "<leader>W",  "<cmd>wa<cr>",  { desc = " Guardar todos" })
map("n", "<leader>q",  "<cmd>confirm q<cr>", { desc = "󰗼 Cerrar ventana" })
map("n", "<leader>Q",  "<cmd>qa!<cr>", { desc = "󰗼 Salir sin guardar" })

-- ============================================================================
-- NAVEGACIÓN ENTRE VENTANAS
-- ============================================================================

map("n", "<C-h>", "<C-w>h", { desc = "Ventana ←" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana ↓" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana ↑" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana →" })

-- ============================================================================
-- WINDOWS / SPLITS (<leader>w)
-- ============================================================================

map("n", "<leader>wv", "<cmd>vsplit<cr>",  { desc = "󰯌 Split vertical" })
map("n", "<leader>wh", "<cmd>split<cr>",   { desc = "󰯌 Split horizontal" })
map("n", "<leader>we", "<C-w>=",           { desc = " Igualar splits" })
map("n", "<leader>wx", "<cmd>close<cr>",   { desc = " Cerrar split" })
map("n", "<leader>wm", "<C-w>o",           { desc = " Maximizar ventana" })

-- Redimensionar splits
map("n", "<C-Up>",    "<cmd>resize +2<cr>",           { desc = "Aumentar alto" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",           { desc = "Reducir alto" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>",  { desc = "Reducir ancho" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",  { desc = "Aumentar ancho" })

-- ============================================================================
-- BUFFERS (<leader>b)
-- ============================================================================

map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "󰒭 Siguiente buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "󰒮 Buffer anterior" })

map("n", "<leader>bd", "<cmd>bdelete<cr>",     { desc = "󰅖 Cerrar buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>",    { desc = "󰅖 Forzar cierre" })
map("n", "<leader>bn", "<cmd>bnext<cr>",       { desc = "󰒭 Siguiente" })
map("n", "<leader>bp", "<cmd>bprevious<cr>",   { desc = "󰒮 Anterior" })
map("n", "<leader>bf", "<cmd>bfirst<cr>",      { desc = "󰮳 Primero" })
map("n", "<leader>bl", "<cmd>blast<cr>",       { desc = "󰮱 Último" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = " Solo actual" })

-- Ir a buffer por número (1-9)
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>",
    { desc = "󰓩 Buffer " .. i })
end

-- ============================================================================
-- EDICIÓN
-- ============================================================================

-- Mover líneas en visual
map("v", "J", ":m '>+1<cr>gv=gv", { desc = " Mover línea abajo" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = " Mover línea arriba" })

-- Scroll centrado
map("n", "<C-d>", "<C-d>zz", { desc = "Bajar (centrado)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Subir (centrado)" })
map("n", "n",     "nzzzv",   { desc = "Siguiente resultado (centrado)" })
map("n", "N",     "Nzzzv",   { desc = "Anterior resultado (centrado)" })

-- Indentación en visual (mantener selección)
map("v", "<", "<gv", { desc = "⇤ Indentar izquierda" })
map("v", ">", ">gv", { desc = "⇥ Indentar derecha" })

-- Portapapeles
map({ "n", "v" }, "<leader>y",  '"+y',  { desc = " Copiar al portapapeles" })
map("n",          "<leader>Y",  '"+Y',  { desc = " Copiar línea al portapapeles" })
map({ "n", "v" }, "<leader>p",  '"+p',  { desc = " Pegar desde portapapeles" })
map("v",          "<leader>P",  '"_dP', { desc = " Pegar sin perder registro" })
map({ "n", "v" }, "<leader>d",  '"_d',  { desc = "󰅗 Eliminar sin registro" })

-- ============================================================================
-- BÚSQUEDA / REEMPLAZAR (<leader>s)
-- ============================================================================

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "󱙈 Limpiar búsqueda" })
map("n", "<leader>sh", "<cmd>nohlsearch<cr>", { desc = "󱙈 Limpiar resaltado" })
map("n", "<leader>sr", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "󰛔 Reemplazar palabra bajo cursor" })
map("n", "<leader>sR", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>",
  { desc = "󰛔 Reemplazar (vacío)" })
map("n", "<leader>sa", "ggVG", { desc = " Seleccionar todo" })

-- ============================================================================
-- DIAGNÓSTICOS / QUICKFIX (<leader>x)
-- ============================================================================

-- Quickfix
map("n", "<leader>xo", "<cmd>copen<cr>",  { desc = " Abrir quickfix" })
map("n", "<leader>xc", "<cmd>cclose<cr>", { desc = " Cerrar quickfix" })
map("n", "]q",         "<cmd>cnext<cr>",  { desc = "󰒭 Siguiente quickfix" })
map("n", "[q",         "<cmd>cprev<cr>",  { desc = "󰒮 Anterior quickfix" })

-- Location list
map("n", "]l", "<cmd>lnext<cr>", { desc = "󰒭 Siguiente location" })
map("n", "[l", "<cmd>lprev<cr>", { desc = "󰒮 Anterior location" })

-- ============================================================================
-- UI TOGGLES (<leader>u)
-- ============================================================================

map("n", "<leader>uw", "<cmd>set wrap!<cr>",         { desc = "󰖶 Toggle wrap" })
map("n", "<leader>us", "<cmd>set spell!<cr>",         { desc = "󰓆 Toggle spell" })
map("n", "<leader>un", "<cmd>set number!<cr>",        { desc = "󰔓 Toggle números" })
map("n", "<leader>ur", "<cmd>set relativenumber!<cr>",{ desc = "󰔓 Toggle relativos" })
map("n", "<leader>uc", "<cmd>set cursorline!<cr>",    { desc = "󰉶 Toggle cursorline" })
map("n", "<leader>ul", "<cmd>set list!<cr>",          { desc = "󱞤 Toggle caracteres ocultos" })

-- ============================================================================
-- PACKAGES (<leader>p)
-- ============================================================================

map("n", "<leader>pl", "<cmd>Lazy<cr>",         { desc = "󰏖 Lazy (plugins)" })
map("n", "<leader>ps", "<cmd>Lazy sync<cr>",    { desc = " Sync plugins" })
map("n", "<leader>pu", "<cmd>Lazy update<cr>",  { desc = "󰚰 Actualizar plugins" })
map("n", "<leader>pc", "<cmd>Lazy clean<cr>",   { desc = "󰃢 Limpiar plugins" })
map("n", "<leader>pp", "<cmd>Lazy profile<cr>", { desc = " Perfil de inicio" })
map("n", "<leader>pm", "<cmd>Mason<cr>",        { desc = " Mason (LSP)" })
map("n", "<leader>pM", "<cmd>MasonUpdate<cr>",  { desc = "󰚰 Actualizar Mason" })

-- ============================================================================
-- SESSION / QUIT (<leader>q)
-- ============================================================================

map("n", "<leader>qs", function() require("persistence").load() end,
  { desc = "󰦛 Restaurar sesión" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
  { desc = "󰦛 Última sesión" })
map("n", "<leader>qd", function() require("persistence").stop() end,
  { desc = " No guardar sesión" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "󰗼 Salir de Neovim" })

-- ============================================================================
-- TERMINAL
-- ============================================================================

map("n", "<leader>T",  "<cmd>terminal<cr>", { desc = " Abrir terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>",       { desc = "Salir del terminal" })

-- ============================================================================
-- UTILIDADES
-- ============================================================================

map("n", "<leader>cx", "<cmd>!chmod +x %<cr>", { silent = true, desc = " Hacer ejecutable" })
map("n", "<leader>rr", "<cmd>source $MYVIMRC<cr>", { desc = "󰑓 Recargar config" })
map("n", "<leader>+",  "<C-a>", { desc = " Incrementar número" })
map("n", "<leader>-",  "<C-x>", { desc = " Decrementar número" })
