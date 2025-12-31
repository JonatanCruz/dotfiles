-- ============================================================================
-- Neodev - Neovim Lua API completion and LSP configuration
-- ============================================================================
-- Provides Neovim API completion, documentation, and type checking for Lua
-- configuration files. Essential for Neovim plugin and config development.
-- Documentación: https://github.com/folke/neodev.nvim
-- ============================================================================

return {
  "folke/neodev.nvim",
  ft = "lua",
  opts = {
    library = {
      plugins = { "nvim-dap-ui" },
      types = true,
    },
    lspconfig = true,
    override = function(root_dir, options)
      -- Enable for Neovim config directory
      if root_dir:find(vim.fn.stdpath("config"), 1, true) == 1 then
        options.enabled = true
        options.plugins = true
      end
    end,
  },
}
