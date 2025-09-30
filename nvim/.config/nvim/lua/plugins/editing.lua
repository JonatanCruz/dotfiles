return {
  -- Plugin para formatear código (conform.nvim)
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        css = { 'prettier' },
        html = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Treesitter para un resaltado de sintaxis inteligente y avanzado
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'javascript', 'html', 'css' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Autocompletado de pares de (), [], {}, "", ''
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} 
  },

  -- Comentar código fácilmente con `gcc` (línea) o `gc` (visual)
  { 
    'numToStr/Comment.nvim',
    opts = {},
  },
}
