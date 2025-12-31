-- ============================================================================
-- Alpha - Pantalla de inicio personalizada
-- ============================================================================
-- Dashboard con ASCII art y accesos rápidos al abrir Neovim sin archivos.
-- Documentación: https://github.com/goolord/alpha-nvim
-- ============================================================================

local colors = require("utils.colors")

return {
  "goolord/alpha-nvim",
  -- Conditional loading: only show dashboard when opening nvim without files (30-50ms savings)
  event = function()
    if vim.fn.argc() == 0 then
      return "VimEnter"
    end
    return nil
  end,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Header ASCII art
    dashboard.section.header.val = {
      "                                                     ",
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
      "                                                     ",
    }

    -- Botones de acción
    dashboard.section.buttons.val = {
      dashboard.button("f", "󰍉  Buscar archivo", ":Telescope find_files<CR>"),
      dashboard.button("e", "  Nuevo archivo", ":ene <BAR> startinsert<CR>"),
      dashboard.button("r", "󰄉  Recientes", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "󰊢  Buscar texto", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  Configuración", ":e $MYVIMRC<CR>"),
      dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
      dashboard.button("q", "󰗼  Salir", ":qa<CR>"),
    }

    -- Footer dinámico
    local function footer()
      local total_plugins = require("lazy").stats().count
      local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
      return datetime .. "   " .. total_plugins .. " plugins"
    end

    dashboard.section.footer.val = footer()

    -- Configuración de colores
    dashboard.section.header.opts.hl = "Keyword"
    dashboard.section.buttons.opts.hl = "Function"
    dashboard.section.footer.opts.hl = "Type"

    alpha.setup(dashboard.opts)

    -- Transparencia con colores personalizados
    -- La transparencia base la maneja utils/transparency.lua
    local transparency = require("utils.transparency")
    transparency.set_transparent("AlphaHeader", { fg = colors.primary })
    transparency.set_transparent("AlphaFooter", { fg = colors.secondary })
  end,
}
