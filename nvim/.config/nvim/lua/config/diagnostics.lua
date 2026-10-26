-- ============================================================================
-- CONFIGURACIÓN DE DIAGNÓSTICOS LSP
-- ============================================================================
-- Sistema completo de visualización y navegación de errores/warnings
-- ============================================================================

-- Iconos del gutter (columna izquierda). Desde Neovim 0.10 se pasan en
-- `vim.diagnostic.config({ signs = { text = ... } })`; los `sign_define`
-- de DiagnosticSign* que se usaban antes se ignoran en 0.12.
-- Glifos Nerd Font: U+F057, U+F071, U+F0335, U+F05A.
local severity = vim.diagnostic.severity
local sign_text = {
  [severity.ERROR] = "",
  [severity.WARN]  = "",
  [severity.HINT]  = "󰌵",
  [severity.INFO]  = "",
}

-- Configuración global de diagnósticos
vim.diagnostic.config({
  -- Texto del diagnóstico al final de la línea
  virtual_text = {
    prefix = "●", -- Prefijo antes del mensaje
    spacing = 4,
    severity = {
      min = vim.diagnostic.severity.HINT, -- Mostrar desde hints hasta errors
    },
  },

  -- Signos en el gutter
  signs = {
    text = sign_text,
    priority = 10, -- Prioridad de signos (mayor = más visible)
  },

  -- Actualización en tiempo real
  update_in_insert = false, -- No actualizar mientras escribes (menos distracciones)

  -- Underline de errores
  underline = true,

  -- Orden
  severity_sort = true, -- Ordenar por severidad (errors primero)

  -- Ventanas flotantes
  float = {
    focusable = true, -- Poder entrar a la ventana flotante
    style = "minimal",
    border = "rounded",
    source = true, -- Mostrar fuente del diagnóstico (eslint, typescript, etc.)
    header = "",
    prefix = "",
    format = function(diagnostic)
      -- Formato personalizado del mensaje
      local name = vim.diagnostic.severity[diagnostic.severity]
      return string.format("[%s] %s", name, diagnostic.message)
    end,
  },
})

-- Bordes de las ventanas flotantes (hover, signature help, diagnósticos).
--
-- Antes se envolvían los handlers con `vim.lsp.with()`, pero esa función se
-- eliminó en Neovim 0.12 (deprecada en 0.11). `winborder` es la opción global
-- que la sustituye: aplica a TODAS las ventanas flotantes de una vez, sin
-- tener que envolver cada handler por separado.
vim.o.winborder = "rounded"
