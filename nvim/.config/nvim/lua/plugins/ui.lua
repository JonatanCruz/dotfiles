return {
  -- Lualine (la barra de estado que ya tenías)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'catppuccin',
      },
    },
  },

  -- Nvim-tree: El explorador de archivos
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Para los iconos
    cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile', 'NvimTreeCollapse' },
    keys = {
      { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Alternar explorador de archivos' },
    },
    init = function()
      -- Abrir NvimTree automáticamente cuando se abre un directorio
      vim.api.nvim_create_autocmd({ 'VimEnter' }, {
        callback = function(data)
          -- El buffer es un directorio
          local directory = vim.fn.isdirectory(data.file) == 1

          if directory then
            vim.cmd.cd(data.file)
            require('nvim-tree.api').tree.open()
          end
        end
      })
    end,
    config = function()
      -- Función para configurar los keymaps personalizados
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Keymaps por defecto recomendados
        api.config.mappings.default_on_attach(bufnr)

        -- Keymaps personalizados
        vim.keymap.set('n', 'l', api.node.open.edit, opts('Abrir'))
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Cerrar carpeta'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Abrir en split vertical'))
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Abrir en split horizontal'))
      end

      require('nvim-tree').setup({
        -- Desactivar netrw (explorador de archivos nativo de vim)
        disable_netrw = true,
        hijack_netrw = true,

        -- Configurar los keymaps
        on_attach = on_attach,

        -- Otras opciones de configuración
        actions = {
          open_file = {
            -- Cierra NvimTree automáticamente después de abrir un archivo
            quit_on_open = true,
          },
        },

        -- Vista del árbol
        view = {
          width = 30,
          side = 'left',
        },

        -- Renderizado
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
            glyphs = {
              folder = {
                arrow_closed = '',
                arrow_open = '',
              },
            },
          },
        },

        -- Filtros
        filters = {
          dotfiles = false,
          custom = { '.DS_Store' },
        },
      })

      -- Hacemos que el fondo de NvimTree y sus ventanas flotantes sean transparentes
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NvimTreeNormalFloat", { link = "Normal" })
      vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "none" })
    end
  },

  -- Which-key: Mostrar keybindings disponibles
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        marks = true,     -- Mostrar marks con m
        registers = true, -- Mostrar registros con "
        spelling = {
          enabled = true,  -- z= para sugerencias de spelling
          suggestions = 20,
        },
        presets = {
          operators = true,    -- Ayuda con operadores como d, y, c
          motions = true,      -- Ayuda con motions
          text_objects = true, -- Ayuda con text objects como iw, i(
          windows = true,      -- Ayuda con comandos de ventanas
          nav = true,          -- Navegación miscelánea
          z = true,            -- Bindings que empiezan con z
          g = true,            -- Bindings que empiezan con g
        },
      },
      win = {
        border = 'rounded',
        padding = { 2, 2, 2, 2 },
      },
      -- Ordenar alfabéticamente
      sort_by_description = false,
      -- Mostrar íconos
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "",  -- Sin prefijo para grupos (los iconos ya están en el nombre)
      },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)

      -- Transparencia completa para which-key (debe ir después de setup)
      vim.api.nvim_set_hl(0, 'WhichKeyFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'WhichKeyBorder', { fg = '#89b4fa', bg = 'none' })
      vim.api.nvim_set_hl(0, 'WhichKeyNormal', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'WhichKeyTitle', { fg = '#89b4fa', bg = 'none' })
      vim.api.nvim_set_hl(0, 'WhichKeyGroup', { fg = '#f5c2e7' })  -- Rosa Catppuccin para grupos
      vim.api.nvim_set_hl(0, 'WhichKeyDesc', { fg = '#cdd6f4' })   -- Texto Catppuccin
      vim.api.nvim_set_hl(0, 'WhichKeyIcon', { fg = '#89b4fa' })   -- Azul Catppuccin para iconos

      -- Registrar grupos de keybindings con descripciones e iconos personalizados
      -- Sintaxis actualizada para which-key v3
      wk.add({
        { '<leader>b', group = 'Buffer', icon = '󰓩' },
        { '<leader>f', group = 'Buscar (Telescope)', icon = '󰍉' },
        { '<leader>g', group = 'Git', icon = '󰊢' },
        { '<leader>h', group = 'Git Hunk', icon = '' },
        { '<leader>l', group = 'Linting', icon = '󰁨' },
        { '<leader>n', group = 'No-highlight', icon = '󰹾' },
        { '<leader>p', group = 'Paquetes (Lazy/Mason)', icon = '󰏖' },
        { '<leader>r', group = 'Reload/Rename', icon = '󰑓' },
        { '<leader>s', group = 'Splits', icon = '󰯌' },
        { '<leader>t', group = 'Toggle/Terminal', icon = '󰔡' },
        { '<leader>x', group = 'Trouble/Diagnósticos', icon = '󰙅' },
      })
    end,
  },

  -- Nvim-notify: Notificaciones modernas
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        background_colour = '#000000', -- Fondo semi-transparente
      })
      vim.notify = require('notify')   -- Reemplaza la función `print` de vim
    end
  },

  -- Indent-blankline: Muestra líneas de guía de indentación
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
      },
      exclude = {
        filetypes = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
      },
    },
  },

  -- Bufferline: Muestra buffers como pestañas en la parte superior
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'catppuccin/nvim' },
    event = 'VeryLazy',
    keys = {
      { '<Tab>', '<cmd>BufferLineCycleNext<cr>', desc = 'Siguiente buffer' },
      { '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Buffer anterior' },
      { '<leader>bp', '<cmd>BufferLinePick<cr>', desc = 'Elegir buffer' },
      { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = 'Cerrar buffer (elegir)' },
    },
    opts = {
      options = {
        mode = 'buffers',
        separator_style = 'slant',
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        diagnostics = 'nvim_lsp',
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'Explorador de Archivos',
            text_align = 'center',
            separator = true,
          },
        },
      },
    },
  },

  -- Nvim-colorizer: Muestra colores hexadecimales/RGB con el color real
  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      filetypes = { '*' },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = 'background',
        tailwind = true,
      },
    },
  },

  -- Alpha-nvim: Pantalla de inicio personalizada
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      -- Header ASCII art
      dashboard.section.header.val = {
        '                                                     ',
        '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
        '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
        '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
        '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
        '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
        '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
        '                                                     ',
      }

      -- Botones de acción
      dashboard.section.buttons.val = {
        dashboard.button('f', '󰍉  Buscar archivo', ':Telescope find_files<CR>'),
        dashboard.button('e', '  Nuevo archivo', ':ene <BAR> startinsert<CR>'),
        dashboard.button('r', '󰄉  Recientes', ':Telescope oldfiles<CR>'),
        dashboard.button('g', '󰊢  Buscar texto', ':Telescope live_grep<CR>'),
        dashboard.button('c', '  Configuración', ':e $MYVIMRC<CR>'),
        dashboard.button('l', '󰒲  Lazy', ':Lazy<CR>'),
        dashboard.button('q', '󰗼  Salir', ':qa<CR>'),
      }

      -- Footer
      local function footer()
        local total_plugins = require('lazy').stats().count
        local datetime = os.date(' %d-%m-%Y   %H:%M:%S')
        return datetime .. '   ' .. total_plugins .. ' plugins'
      end

      dashboard.section.footer.val = footer()

      -- Configuración de colores
      dashboard.section.header.opts.hl = 'Keyword'
      dashboard.section.buttons.opts.hl = 'Function'
      dashboard.section.footer.opts.hl = 'Type'

      -- Transparencia
      vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = '#89b4fa', bg = 'none' })
      vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = '#f5c2e7', bg = 'none' })

      alpha.setup(dashboard.opts)
    end,
  },

  -- Dressing.nvim: Mejora los inputs y selects de vim
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      input = {
        enabled = true,
        default_prompt = '➤ ',
        win_options = {
          winblend = 0,
        },
      },
      select = {
        enabled = true,
        backend = { 'telescope', 'builtin' },
        builtin = {
          win_options = {
            winblend = 0,
          },
        },
      },
    },
  },

  -- Todo-comments: Resalta comentarios TODO, HACK, NOTE, etc
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', color = 'default', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      },
    },
    keys = {
      { '<leader>ft', '<cmd>TodoTelescope<cr>', desc = 'Buscar TODOs' },
    },
  },
}
