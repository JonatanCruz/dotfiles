-- ============================================================================
-- INCLINE
-- ============================================================================
-- Muestra el nombre del archivo en una ventana flotante por cada split

return {
  "b0o/incline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    highlight = {
      groups = {
        InclineNormal = { guibg = "#1e1e2e", guifg = "#cdd6f4" },
        InclineNormalNC = { guibg = "#181825", guifg = "#6c7086" },
      },
    },
    window = {
      padding = 0,
      margin = { horizontal = 0, vertical = 0 },
    },
    hide = {
      cursorline = true,
      focused_win = false,
      only_win = true,
    },
    render = function(props)
      local devicons = require("nvim-web-devicons")
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      if filename == "" then
        filename = "[Sin nombre]"
      end
      local ft_icon, ft_color = devicons.get_icon_color(filename)
      local modified = vim.bo[props.buf].modified

      return {
        ft_icon and { " ", ft_icon, " ", guifg = ft_color } or "",
        " ",
        { filename, gui = modified and "bold,italic" or "bold" },
        modified and { " ", "", guifg = "#f38ba8" } or "",
        " ",
      }
    end,
  },
}
