-- ============================================================================
-- Supermaven - Autocompletado AI Optimizado
-- ============================================================================
-- Autocompletado impulsado por IA en tiempo real. Gratuito con 1M token context.
-- Documentación: https://github.com/supermaven-inc/supermaven-nvim
--
-- Comandos útiles:
-- :SupermavenStart      - Iniciar Supermaven
-- :SupermavenStop       - Detener Supermaven
-- :SupermavenToggle     - Toggle Supermaven
-- :SupermavenUseFree    - Usar tier gratuito (primera vez)
-- :SupermavenShowLog    - Ver logs
-- :SupermavenStatus     - Ver estado actual
-- ============================================================================

local colors = require("utils.colors")

return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter", -- Carga solo al entrar en modo INSERT (más eficiente)
  keys = {
    { "<leader>ai", "<cmd>SupermavenToggle<cr>", desc = "Toggle Supermaven AI", mode = "n" },
    { "<leader>as", "<cmd>SupermavenStatus<cr>", desc = "Supermaven Status", mode = "n" },
    { "<leader>al", "<cmd>SupermavenShowLog<cr>", desc = "Supermaven Logs", mode = "n" },
  },
  config = function()
    require("supermaven-nvim").setup({
      -- ================================================================
      -- KEYMAPS OPTIMIZADOS (Alineados con nvim-cmp)
      -- ================================================================
      -- NOTA: Evita conflictos con tmux-navigator (<C-h/j/k/l> en NORMAL)
      -- y sigue convenciones de nvim-cmp para consistencia
      keymaps = {
        accept_suggestion = "<C-y>",    -- Ctrl+y: Aceptar sugerencia (convención nvim-cmp "yes")
        clear_suggestion = "<C-e>",     -- Ctrl+e: Rechazar sugerencia (convención "escape")
        accept_word = "<M-l>",          -- Alt+l: Aceptar solo próxima palabra
      },

      -- ================================================================
      -- TIPOS DE ARCHIVO A IGNORAR
      -- ================================================================
      ignore_filetypes = {
        -- UI y plugins
        "TelescopePrompt",
        "NvimTree",
        "lazy",
        "mason",
        "trouble",
        "alpha",
        "dashboard",

        -- Archivos especiales
        "gitcommit",
        "gitrebase",
        "help",
        "man",

        -- Buffers especiales
        "terminal",
        "toggleterm",
        "prompt",
        "qf",  -- quickfix
      },

      -- ================================================================
      -- CONFIGURACIÓN VISUAL
      -- ================================================================
      color = {
        suggestion_color = colors.comment, -- Gris tenue para sugerencias
        cterm = 244,
      },

      -- ================================================================
      -- CONFIGURACIÓN DE RENDIMIENTO
      -- ================================================================
      log_level = "warn",  -- Solo warnings y errores (menos verboso)
      disable_inline_completion = false,
      disable_keymaps = false,

      -- ================================================================
      -- CONDICIÓN DE ACTIVACIÓN
      -- ================================================================
      condition = function()
        -- No activar en archivos muy grandes (>1MB para mejor rendimiento)
        local max_filesize = 1024 * 1024 -- 1 MB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and stats.size > max_filesize then
          return false
        end
        return true
      end,
    })

    -- ================================================================
    -- AUTOCOMANDOS PARA MEJOR UX
    -- ================================================================
    local augroup = vim.api.nvim_create_augroup("SupermavenConfig", { clear = true })

    -- Mostrar mensaje cuando Supermaven está activo en statusline
    vim.api.nvim_create_autocmd("User", {
      pattern = "SupermavenStart",
      group = augroup,
      callback = function()
        vim.notify("Supermaven AI activado", vim.log.levels.INFO, { title = "Supermaven" })
      end,
    })

    -- Notificar cuando se detiene
    vim.api.nvim_create_autocmd("User", {
      pattern = "SupermavenStop",
      group = augroup,
      callback = function()
        vim.notify("Supermaven AI desactivado", vim.log.levels.WARN, { title = "Supermaven" })
      end,
    })
  end,
}
