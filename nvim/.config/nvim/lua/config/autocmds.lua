-- ============================================================================
-- AUTOCOMANDOS DE NEOVIM
-- ============================================================================
-- Automatizaciones que se ejecutan en eventos específicos

-- ============================================================================
-- INTEGRACIÓN CON TMUX
-- ============================================================================

local tmux_integration = vim.api.nvim_create_augroup("TmuxIntegration", { clear = true })

-- Oculta la barra de estado de tmux al entrar a Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  group = tmux_integration,
  pattern = "*",
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux set-option -g status off")
    end
  end,
  desc = "Ocultar barra de estado de tmux al entrar a Neovim"
})

-- Muestra la barra de estado de tmux al salir de Neovim
vim.api.nvim_create_autocmd("VimLeave", {
  group = tmux_integration,
  pattern = "*",
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux set-option -g status on")
    end
  end,
  desc = "Mostrar barra de estado de tmux al salir de Neovim"
})

-- ============================================================================
-- MEJORAS DE EDICIÓN
-- ============================================================================

local editing_group = vim.api.nvim_create_augroup("EditingImprovements", { clear = true })

-- Resalta el texto copiado brevemente
vim.api.nvim_create_autocmd("TextYankPost", {
  group = editing_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
  desc = "Resaltar texto copiado"
})

-- Elimina espacios en blanco al final de las líneas al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
  group = editing_group,
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Eliminar espacios en blanco al final de líneas"
})

-- ============================================================================
-- MEJORAS DE INTERFAZ
-- ============================================================================

local ui_group = vim.api.nvim_create_augroup("UIImprovements", { clear = true })

-- Recuerda la última posición del cursor en archivos
vim.api.nvim_create_autocmd("BufReadPost", {
  group = ui_group,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Recordar última posición del cursor"
})

-- Cierra automáticamente ciertos tipos de ventanas con 'q'
vim.api.nvim_create_autocmd("FileType", {
  group = ui_group,
  pattern = { "qf", "help", "man", "lspinfo", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  desc = "Cerrar ventanas especiales con 'q'"
})

-- ============================================================================
-- CONFIGURACIONES POR TIPO DE ARCHIVO
-- ============================================================================

local filetype_group = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })

-- Configuración para archivos de texto (Markdown, txt, etc.)
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_group,
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "es,en"
  end,
  desc = "Configuración para archivos de texto"
})
