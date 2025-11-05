-- ============================================================================
-- Which-key - Mostrar keybindings disponibles
-- ============================================================================
-- Muestra sugerencias de keybindings mientras escribes con íconos personalizados.
-- Documentación: https://github.com/folke/which-key.nvim
-- ============================================================================

local icons = require("utils.icons")
local colors = require("utils.colors")

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = "rounded",
      padding = { 2, 2, 2, 2 },
    },
    sort_by_description = false,
    icons = {
      breadcrumb = icons.separators.breadcrumb,
      separator = icons.separators.arrow,
      group = "",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Transparencia y colores personalizados
    -- La transparencia base la maneja utils/transparency.lua
    -- Aquí solo configuramos los colores específicos
    local transparency = require("utils.transparency")
    transparency.set_transparent("WhichKeyFloat")
    transparency.set_transparent("WhichKeyBorder", { fg = colors.primary })
    transparency.set_transparent("WhichKeyNormal")
    transparency.set_transparent("WhichKeyTitle", { fg = colors.primary })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = colors.secondary, bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = colors.fg, bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyIcon", { fg = colors.primary, bg = "none" })

    -- Registrar grupos de keybindings con descripciones e íconos
    wk.add({
      { "<leader>b", group = "Buffer", icon = icons.whichkey.buffer },
      { "<leader>d", group = "Debug (DAP)", icon = "" },
      { "<leader>f", group = "Buscar (Telescope)", icon = icons.whichkey.search },
      { "<leader>g", group = "Git", icon = icons.whichkey.git },
      { "<leader>h", group = "Git Hunk", icon = icons.whichkey.hunk },
      { "<leader>l", group = "Linting", icon = icons.whichkey.lint },
      { "<leader>n", group = "No-highlight", icon = icons.whichkey.no_highlight },
      { "<leader>o", group = "Outline/Symbols", icon = icons.whichkey.outline },
      { "<leader>p", group = "Paquetes (Lazy/Mason)", icon = icons.whichkey.packages },
      { "<leader>q", group = "Quit/Session", icon = "󰗼" },
      { "<leader>r", group = "Refactor/Rename", icon = icons.whichkey.reload },
      { "<leader>s", group = "System/Mensajes (Noice)", icon = icons.whichkey.system },
      { "<leader>t", group = "Toggle/Terminal", icon = icons.whichkey.toggle },
      { "<leader>x", group = "Trouble/Diagnósticos", icon = icons.whichkey.diagnostics },
    })
  end,
}
