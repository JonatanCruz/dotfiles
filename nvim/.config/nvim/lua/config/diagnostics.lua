-- ============================================================================
-- CONFIGURACIÓN DE DIAGNÓSTICOS LSP
-- ============================================================================
-- Sistema completo de visualización y navegación de errores/warnings
-- ============================================================================

-- Signos en el gutter (columna izquierda)
local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

-- Configuración global de diagnósticos
vim.diagnostic.config({
  -- Ventana flotante automática al hacer hover sobre error
  virtual_text = {
    enabled = true,
    prefix = "●", -- Prefijo antes del mensaje
    spacing = 4,
    severity = {
      min = vim.diagnostic.severity.HINT, -- Mostrar desde hints hasta errors
    },
  },

  -- Signos en el gutter
  signs = {
    active = signs,
    priority = 10, -- Prioridad de signos (mayor = más visible)
  },

  -- Actualización en tiempo real
  update_in_insert = false, -- No actualizar mientras escribes (menos distracciones)

  -- Underline de errores
  underline = true,

  -- Severidad mínima
  severity_sort = true, -- Ordenar por severidad (errors primero)

  -- Ventanas flotantes
  float = {
    focusable = true, -- Poder entrar a la ventana flotante
    style = "minimal",
    border = "rounded",
    source = "always", -- Mostrar fuente del diagnóstico (eslint, typescript, etc.)
    header = "",
    prefix = "",
    format = function(diagnostic)
      -- Formato personalizado del mensaje
      local severity = vim.diagnostic.severity[diagnostic.severity]
      return string.format("[%s] %s", severity, diagnostic.message)
    end,
  },
})

-- Configuración de ventanas flotantes para hover
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  max_width = 80,
})

-- Configuración de ventanas flotantes para signature help
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  max_width = 80,
})
