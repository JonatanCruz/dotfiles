-- ============================================================================
-- Noice.nvim - UI mejorada para mensajes, comandos y notificaciones
-- ============================================================================
-- Reemplaza la UI de mensajes, cmdline y popupmenu de Neovim con una interfaz
-- moderna y personalizable. Integración completa con nvim-notify.
-- Documentación: https://github.com/folke/noice.nvim
--
-- Comandos útiles:
-- :Noice - Ver historial de mensajes
-- :Noice dismiss - Cerrar todas las notificaciones
-- :Noice stats - Ver estadísticas de rendimiento
-- :Noice telescope - Buscar mensajes con Telescope
-- ============================================================================

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  keys = {
    { "<leader>sn", "<cmd>Noice<cr>", desc = "Historial de mensajes Noice" },
    { "<leader>sl", "<cmd>Noice last<cr>", desc = "Último mensaje Noice" },
    { "<leader>sd", "<cmd>Noice dismiss<cr>", desc = "Cerrar notificaciones" },
  },
  opts = function()
    local icons = require("utils.icons")
    local constants = require("config.constants")

    return {
      lsp = {
      -- Override markdown rendering para que funcione con Treesitter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      -- Mostrar progreso de LSP
      progress = {
        enabled = true,
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30,
        view = "mini",
      },
      -- Hover y signature help con borders
      hover = {
        enabled = true,
        silent = false,
        view = nil,
        opts = {},
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
          trigger = true,
          luasnip = true,
          throttle = 50,
        },
        view = nil,
        opts = {},
      },
      message = {
        enabled = true,
        view = "notify",
        opts = {},
      },
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },
    -- Presets para una mejor experiencia
    presets = {
      bottom_search = true,        -- Barra de búsqueda en la parte inferior
      command_palette = true,       -- Paleta de comandos estilo VSCode
      long_message_to_split = true, -- Mensajes largos en split
      inc_rename = false,           -- Input para inc-rename.nvim
      lsp_doc_border = true,        -- Bordes en documentación LSP
    },
    -- Configuración de cmdline
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = {
          pattern = "^:",
          icon = icons.ui.command or ":",
          lang = "vim",
        },
        search_down = {
          kind = "search",
          pattern = "^/",
          icon = icons.ui.search .. " ",
          lang = "regex",
        },
        search_up = {
          kind = "search",
          pattern = "^%?",
          icon = icons.ui.search .. " ",
          lang = "regex",
        },
        filter = {
          pattern = "^:%s*!",
          icon = "$",
          lang = "bash",
        },
        lua = {
          pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
          icon = icons.kind.Module or "",
          lang = "lua",
        },
        help = {
          pattern = "^:%s*he?l?p?%s+",
          icon = icons.ui.question or "?",
        },
        input = {},
      },
    },
    -- Configuración de mensajes
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "messages",
      view_search = "virtualtext",
    },
    -- Configuración de popupmenu
    popupmenu = {
      enabled = true,
      backend = "nui",
      kind_icons = {},
    },
    -- Rutas de mensajes personalizadas
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "more lines",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "fewer lines",
        },
        opts = { skip = true },
      },
    },
    -- Notificaciones
    notify = {
      enabled = true,
      view = "notify",
    },
    -- Transparencia gestionada globalmente en utils/transparency.lua
    views = {
      cmdline_popup = {
        border = {
          style = constants.borders.style,
        },
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = 8,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = constants.borders.style,
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
    }
  end,
}
