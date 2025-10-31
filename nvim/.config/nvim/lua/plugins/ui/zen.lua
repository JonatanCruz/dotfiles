-- ============================================================================
-- Zen Mode - Modo enfocado sin distracciones
-- ============================================================================
-- Centra el contenido y oculta elementos de UI para escritura enfocada.
-- Documentación: https://github.com/folke/zen-mode.nvim
-- ============================================================================

return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Activar/Desactivar Zen Mode" },
  },
  opts = {
    window = {
      backdrop = 0.95, -- Sombra de fondo (0-1)
      width = 120,     -- Ancho de la ventana centrada
      height = 1,      -- 100% de altura
      options = {
        signcolumn = "no",      -- Ocultar columna de signos
        number = false,         -- Ocultar números de línea
        relativenumber = false, -- Ocultar números relativos
        cursorline = false,     -- Ocultar línea del cursor
        cursorcolumn = false,   -- Ocultar columna del cursor
        foldcolumn = "0",       -- Ocultar columna de pliegues
        list = false,           -- Ocultar caracteres invisibles
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,   -- Ocultar ruler
        showcmd = false, -- Ocultar comando en statusline
      },
      twilight = { enabled = false }, -- Desactivar twilight por defecto
      gitsigns = { enabled = false }, -- Ocultar git signs
      tmux = { enabled = false },     -- No cambiar tmux status
      kitty = {
        enabled = false,
        font = "+4", -- Aumentar fuente en kitty
      },
    },
    on_open = function()
      -- Opcional: ejecutar comandos al abrir zen mode
    end,
    on_close = function()
      -- Opcional: ejecutar comandos al cerrar zen mode
    end,
  },
}
