-- ============================================================================
-- Nvim-tree - Explorador de archivos
-- ============================================================================
-- Explorador de archivos con navegación tipo vim (l/h para abrir/cerrar).
-- Auto-apertura al ejecutar `nvim .`
-- Documentación: https://github.com/nvim-tree/nvim-tree.lua
-- ============================================================================

local icons = require("utils.icons")

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeCollapse" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Alternar explorador de archivos" },
  },
  init = function()
    -- Abrir NvimTree automáticamente cuando se abre un directorio
    vim.api.nvim_create_autocmd({ "VimEnter" }, {
      callback = function(data)
        local directory = vim.fn.isdirectory(data.file) == 1
        if directory then
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open()
        end
      end,
    })
  end,
  config = function()
    -- Función para configurar los keymaps personalizados
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Keymaps por defecto recomendados
      api.config.mappings.default_on_attach(bufnr)

      -- Keymaps personalizados (vim-style)
      vim.keymap.set("n", "l", api.node.open.edit, opts("Abrir"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Cerrar carpeta"))
      vim.keymap.set("n", "v", api.node.open.vertical, opts("Abrir en split vertical"))
      vim.keymap.set("n", "s", api.node.open.horizontal, opts("Abrir en split horizontal"))
    end

    require("nvim-tree").setup({
      -- Desactivar netrw (explorador de archivos nativo de vim)
      disable_netrw = true,
      hijack_netrw = true,

      -- Configurar los keymaps
      on_attach = on_attach,

      -- Otras opciones de configuración
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },

      -- Vista del árbol
      view = {
        width = 30,
        side = "left",
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
              arrow_closed = icons.file.folder_closed,
              arrow_open = icons.file.folder_open,
            },
          },
        },
      },

      -- Filtros
      filters = {
        dotfiles = false,
        custom = { ".DS_Store" },
      },
    })

    -- Transparencia (gestionada por utils/transparency.lua en colorscheme)
    -- Los highlights se configuran automáticamente
  end,
}
