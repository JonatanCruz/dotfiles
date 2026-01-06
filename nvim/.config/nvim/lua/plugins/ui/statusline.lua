-- ============================================================================
-- Lualine - Barra de estado elegante
-- ============================================================================
-- Statusline moderna con soporte de íconos y temas.
-- Documentación: https://github.com/nvim-lualine/lualine.nvim
-- ============================================================================

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "catppuccin",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        { "filename", path = 1 },  -- Show relative path
        { "diagnostics", sources = { "nvim_lsp" } },
        {
          "diff",
          symbols = { added = " ", modified = " ", removed = " " },
        },
      },
      lualine_x = {
        {
          function()
            return require("lazy.status").updates()
          end,
          cond = function()
            return require("lazy.status").has_updates()
          end,
          color = { fg = "#ff9e64" },
        },
        { "encoding" },
        { "fileformat" },
        { "filetype" },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
