-- ============================================================================
-- Aerial.nvim - Symbol outline y navegación rápida
-- ============================================================================
-- Proporciona un panel lateral con símbolos del archivo actual (funciones,
-- clases, variables, etc.) para navegación rápida en archivos grandes.
-- Usa LSP como fuente primaria y Treesitter como fallback.
-- Documentación: https://github.com/stevearc/aerial.nvim
-- ============================================================================

return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  -- Lazy loading: solo cargar cuando se use cualquier comando aerial
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline" },
    { "<leader>ot", "<cmd>AerialToggle<cr>", desc = "Toggle Outline (Treesitter)" },
    { "<leader>on", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
    { "<leader>op", "<cmd>AerialPrev<cr>", desc = "Previous Symbol" },
    -- NOTA: { y } se mantienen como nativos de Vim (moverse entre párrafos)
    -- Dentro del panel Aerial, { y } navegarán entre símbolos
  },
  opts = {
    -- ========================================================================
    -- Backends: Prioridad LSP > Treesitter > Markdown > Man
    -- ========================================================================
    backends = { "lsp", "treesitter", "markdown", "man" },

    -- ========================================================================
    -- Layout: Panel a la derecha con ancho adaptativo
    -- ========================================================================
    layout = {
      max_width = { 40, 0.2 }, -- 40 caracteres o 20% de ancho de ventana (lo que sea menor)
      width = nil,             -- nil = usar max_width
      min_width = 25,          -- Ancho mínimo
      default_direction = "right", -- Panel a la derecha
      placement = "edge",      -- Colocar en el borde de la ventana
      resize_to_content = true, -- Ajustar tamaño al contenido
      preserve_equality = false, -- No preservar igualdad de tamaño con otras ventanas
    },

    -- ========================================================================
    -- Filtrado: Solo mostrar símbolos principales
    -- ========================================================================
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Module",
      "Method",
      "Struct",
    },

    -- ========================================================================
    -- Icons: Auto-detección de Nerd Font
    -- ========================================================================
    icons = {}, -- Auto-detect desde nvim-web-devicons
    nerd_font = "auto", -- Auto-detectar si Nerd Font está disponible

    -- ========================================================================
    -- Comportamiento
    -- ========================================================================
    attach_mode = "window", -- Attach por ventana (no por buffer)
    close_automatic_events = {}, -- No cerrar automáticamente
    close_on_select = false, -- No cerrar al seleccionar un símbolo
    highlight_mode = "split_width", -- Modo de highlight
    highlight_closest = true, -- Highlight del símbolo más cercano al cursor
    highlight_on_hover = true, -- Highlight al hacer hover
    highlight_on_jump = 300, -- Duración del highlight al saltar (ms)

    -- ========================================================================
    -- Keymaps internos del panel Aerial
    -- ========================================================================
    keymaps = {
      -- Ayuda
      ["?"] = "actions.show_help",
      ["g?"] = "actions.show_help",

      -- Navegación básica
      ["<CR>"] = "actions.jump",
      ["<2-LeftMouse>"] = "actions.jump",
      ["o"] = "actions.jump",

      -- Splits
      ["<C-v>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",

      -- Scroll
      ["p"] = "actions.scroll",
      ["<C-j>"] = "actions.down_and_scroll",
      ["<C-k>"] = "actions.up_and_scroll",

      -- Navegación por símbolos
      ["{"] = "actions.prev",
      ["}"] = "actions.next",
      ["[["] = "actions.prev_up",
      ["]]"] = "actions.next_up",

      -- Cerrar
      ["q"] = "actions.close",

      -- Tree folding (estilo Vim)
      ["za"] = "actions.tree_toggle",
      ["zA"] = "actions.tree_toggle_recursive",
      ["zo"] = "actions.tree_open",
      ["zO"] = "actions.tree_open_recursive",
      ["zc"] = "actions.tree_close",
      ["zC"] = "actions.tree_close_recursive",
      ["zr"] = "actions.tree_increase_fold_level",
      ["zR"] = "actions.tree_open_all",
      ["zm"] = "actions.tree_decrease_fold_level",
      ["zM"] = "actions.tree_close_all",
      ["zx"] = "actions.tree_sync_folds",
      ["zX"] = "actions.tree_sync_folds",

      -- Tree navigation (alternativas)
      ["l"] = "actions.tree_open",
      ["L"] = "actions.tree_open_recursive",
      ["h"] = "actions.tree_close",
      ["H"] = "actions.tree_close_recursive",
    },

    -- ========================================================================
    -- LSP: Configuración de actualización
    -- ========================================================================
    lsp = {
      diagnostics_trigger_update = true, -- Actualizar al recibir diagnósticos
      update_when_errors = true,         -- Actualizar incluso con errores
      update_delay = 300,                -- Delay de actualización (ms)
      priority = {                       -- Prioridad de símbolos LSP
        -- Priorizar Method > Function para lenguajes OOP
        Method = 10,
        Function = 9,
        Constructor = 8,
        Class = 7,
        Interface = 6,
        Struct = 5,
        Enum = 4,
      },
    },

    -- ========================================================================
    -- Treesitter: Configuración de actualización
    -- ========================================================================
    treesitter = {
      update_delay = 300, -- Delay de actualización (ms)
    },

    -- ========================================================================
    -- Markdown: Configuración específica
    -- ========================================================================
    markdown = {
      update_delay = 300, -- Delay de actualización (ms)
    },

    -- ========================================================================
    -- Navegación: Configuración de auto-navegación
    -- ========================================================================
    autojump = false, -- No saltar automáticamente al seleccionar
    open_automatic = false, -- No abrir automáticamente al entrar a un buffer
    post_jump_cmd = "normal! zz", -- Centrar pantalla después de saltar
    post_add_all_buffers = false, -- No agregar todos los buffers automáticamente

    -- ========================================================================
    -- Show guides: Líneas de guía para niveles de indentación
    -- ========================================================================
    guides = {
      mid_item = "├─",
      last_item = "└─",
      nested_top = "│ ",
      whitespace = "  ",
    },

    -- ========================================================================
    -- Manage folds: Sincronizar folds con Aerial
    -- ========================================================================
    manage_folds = false, -- No manejar folds automáticamente
    link_folds_to_tree = false, -- No linkear folds con el tree
    link_tree_to_folds = false, -- No linkear tree con folds
  },

  -- ========================================================================
  -- Config: Post-setup personalización
  -- ========================================================================
  config = function(_, opts)
    require("aerial").setup(opts)

    -- Configuración de colores Dracula con transparencia
    local colors = require("utils.colors")
    local transparency = require("utils.transparency")

    -- Panel con transparencia
    transparency.set_transparent("AerialNormal")
    transparency.set_transparent("AerialNormalNC")
    transparency.set_transparent("AerialBorder", { fg = colors.primary })

    -- Símbolos con colores Dracula
    vim.api.nvim_set_hl(0, "AerialLine", { bg = colors.catppuccin.surface0 })
    vim.api.nvim_set_hl(0, "AerialGuide", { fg = colors.catppuccin.overlay0, bg = "none" })

    -- Icons específicos por tipo de símbolo (colores Dracula)
    vim.api.nvim_set_hl(0, "AerialClass", { fg = colors.secondary, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialFunction", { fg = colors.catppuccin.green, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialMethod", { fg = colors.catppuccin.green, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialInterface", { fg = colors.catppuccin.mauve, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialStruct", { fg = colors.secondary, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialEnum", { fg = colors.catppuccin.peach, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialConstructor", { fg = colors.catppuccin.yellow, bg = "none" })
    vim.api.nvim_set_hl(0, "AerialModule", { fg = colors.primary, bg = "none" })
  end,
}
