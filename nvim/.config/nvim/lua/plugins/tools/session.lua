-- ============================================================================
-- Persistence - Session management con auto-save y restore
-- ============================================================================
-- Mantiene contexto entre sesiones (buffers, tabs, ventanas, directorio).
-- Documentación: https://github.com/folke/persistence.nvim
-- ============================================================================

return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- Cargar antes de leer buffers para detectar sesiones

  opts = {
    -- Directorio donde se guardan las sesiones
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),

    -- Opciones de sesión a guardar
    -- buffers: buffers abiertos
    -- curdir: directorio actual
    -- tabpages: pestañas
    -- winsize: tamaño de ventanas
    options = { "buffers", "curdir", "tabpages", "winsize" },

    -- Hook antes de guardar (nil = sin hook personalizado)
    pre_save = nil,

    -- No guardar sesiones vacías (sin buffers)
    save_empty = false,
  },

  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    -- Keybindings para session management
    -- Patrón: <leader>q (quit/session)
    local keymap = vim.keymap.set

    -- <leader>qs → Restore session (current dir)
    keymap("n", "<leader>qs", function()
      persistence.load()
    end, { desc = "Restore session (current dir)", silent = true })

    -- <leader>ql → Restore last session
    keymap("n", "<leader>ql", function()
      persistence.load({ last = true })
    end, { desc = "Restore last session", silent = true })

    -- <leader>qd → Don't save session (stop auto-save)
    keymap("n", "<leader>qd", function()
      persistence.stop()
    end, { desc = "Don't save current session", silent = true })

    -- <leader>qq → Quit without saving session
    keymap("n", "<leader>qq", function()
      persistence.stop()
      vim.cmd("qa")
    end, { desc = "Quit without saving session", silent = true })

    -- <leader>qQ → Quit and save session
    keymap("n", "<leader>qQ", function()
      persistence.save()
      vim.cmd("qa")
    end, { desc = "Quit and save session", silent = true })

    -- Auto-save de sesión al salir de Neovim
    -- (persistence.nvim ya maneja esto internamente con VimLeavePre)
    -- No necesitamos autocmd adicional
  end,
}
