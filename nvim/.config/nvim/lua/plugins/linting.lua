return {
  -- nvim-lint: Linting asíncrono
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')

      -- Configurar linters por tipo de archivo
      lint.linters_by_ft = {
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        vue = { 'eslint' },
        svelte = { 'eslint' },
        astro = { 'eslint' },
        css = { 'stylelint' },
        scss = { 'stylelint' },
        sass = { 'stylelint' },
        less = { 'stylelint' },
        python = { 'pylint' },
        lua = { 'luacheck' },
        markdown = { 'markdownlint' },
        yaml = { 'yamllint' },
        json = { 'jsonlint' },
        dockerfile = { 'hadolint' },
        bash = { 'shellcheck' },
        sh = { 'shellcheck' },
      }

      -- Autocomando para ejecutar linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Solo ejecutar si el buffer es modificable y es un archivo
          if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
            lint.try_lint()
          end
        end,
      })

      -- Comando manual para ejecutar linting
      vim.api.nvim_create_user_command('Lint', function()
        lint.try_lint()
      end, { desc = 'Ejecutar linting en el buffer actual' })

      -- Keymap para ejecutar linting manualmente
      vim.keymap.set('n', '<leader>ll', function()
        lint.try_lint()
      end, { desc = 'Ejecutar linting' })
    end,
  },
}
