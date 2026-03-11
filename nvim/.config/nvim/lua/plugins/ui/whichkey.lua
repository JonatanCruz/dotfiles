-- ============================================================================
-- Which-key - Guía de keybindings con íconos
-- ============================================================================

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true, suggestions = 20 },
      presets = {
        operators = true, motions = true, text_objects = true,
        windows = true, nav = true, z = true, g = true,
      },
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
    icons = {
      breadcrumb = "»",
      separator  = "➜",
      group      = " ",
      rules = false, -- usar íconos manuales de los grupos
    },
    show_help = true,
    show_keys = true,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Colores integrados con el tema
    local colors = require("utils.colors")
    local transparency = require("utils.transparency")
    transparency.set_transparent("WhichKeyFloat")
    transparency.set_transparent("WhichKeyBorder", { fg = colors.primary })
    transparency.set_transparent("WhichKeyNormal")
    transparency.set_transparent("WhichKeyTitle",  { fg = colors.primary })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = colors.secondary, bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc",  { fg = colors.fg,        bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyIcon",  { fg = colors.primary,   bg = "none" })

    -- =====================================================================
    -- GRUPOS DE KEYBINDINGS
    -- =====================================================================
    wk.add({
      -- Top-level
      { "<leader>w",  group = "Windows / Splits",  icon = "󰯌" },
      { "<leader>b",  group = "Buffers",            icon = "󰓩" },
      { "<leader>c",  group = "Código / LSP",       icon = "" },
      { "<leader>d",  group = "Debug (DAP)",         icon = "" },
      { "<leader>e",  group = "Explorer",            icon = "󰙅" },
      { "<leader>f",  group = "Find / Telescope",   icon = "󰍉" },
      { "<leader>g",   group = "Git",                icon = "󰊢" },
      { "<leader>gh",  group = "Hunks",             icon = "" },
      { "<leader>gf",  group = "File History",      icon = "󰋚" },
      { "<leader>gt",  group = "Toggles Git",       icon = "󰔡" },
      { "<leader>o",  group = "Outline",            icon = "󰘦" },
      { "<leader>p",  group = "Packages",           icon = "󰏖" },
      { "<leader>q",  group = "Quit / Sesión",      icon = "󰗼" },
      { "<leader>r",  group = "Refactor",           icon = "" },
      { "<leader>s",  group = "Search / Replace",   icon = "󰛔" },
      { "<leader>t",  group = "Tests",              icon = "" },
      { "<leader>u",  group = "UI Toggles",         icon = "󰔡" },
      { "<leader>x",  group = "Diagnósticos",       icon = "󱖫" },
      { "<leader>z",  group = "Zen / Focus",        icon = "󰰶" },

      -- Navegación git
      { "]",  group = "Siguiente →",  icon = "󰒭" },
      { "[",  group = "← Anterior",   icon = "󰒮" },

      -- g* (LSP navigation — documentado para which-key)
      { "g",   group = "Go to / LSP", icon = "" },
      { "gd",  desc  = "Ir a definición",     icon = "" },
      { "gD",  desc  = "Ir a declaración",    icon = "" },
      { "gi",  desc  = "Ir a implementación", icon = "" },
      { "gt",  desc  = "Ir a tipo",           icon = "" },
      { "gr",  desc  = "Referencias",         icon = "" },
      { "gR",  desc  = "Referencias (Trouble)", icon = "󱖫" },
      { "gK",  desc  = "Firma de función",    icon = "" },
    })
  end,
}
