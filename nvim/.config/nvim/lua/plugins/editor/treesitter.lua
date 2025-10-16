-- ============================================================================
-- Treesitter - Resaltado de sintaxis inteligente
-- ============================================================================
-- Parser de sintaxis avanzado para mejor resaltado y comprensión del código.
-- Documentación: https://github.com/nvim-treesitter/nvim-treesitter
-- ============================================================================

local constants = require("config.constants")

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = constants.treesitter.ensure_installed,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
