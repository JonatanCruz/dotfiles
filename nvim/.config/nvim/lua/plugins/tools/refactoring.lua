-- ============================================================================
-- Refactoring.nvim - Operaciones avanzadas de refactoring
-- ============================================================================
-- Extract function, inline variable, extract variable, y más operaciones
-- de refactoring automatizadas con soporte Treesitter.
-- Documentación: https://github.com/ThePrimeagen/refactoring.nvim
-- ============================================================================

return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    -- ========================================================================
    -- Extract operations (Visual mode)
    -- ========================================================================
    {
      "<leader>re",
      function()
        require("refactoring").refactor("Extract Function")
      end,
      mode = "x",
      desc = "Extract Function",
    },
    {
      "<leader>rf",
      function()
        require("refactoring").refactor("Extract Function To File")
      end,
      mode = "x",
      desc = "Extract Function To File",
    },
    {
      "<leader>rv",
      function()
        require("refactoring").refactor("Extract Variable")
      end,
      mode = "x",
      desc = "Extract Variable",
    },

    -- ========================================================================
    -- Inline operations (Normal & Visual mode)
    -- ========================================================================
    {
      "<leader>ri",
      function()
        require("refactoring").refactor("Inline Variable")
      end,
      mode = { "n", "x" },
      desc = "Inline Variable",
    },
    {
      "<leader>rI",
      function()
        require("refactoring").refactor("Inline Function")
      end,
      mode = "n",
      desc = "Inline Function",
    },

    -- ========================================================================
    -- Extract block operations (Normal mode)
    -- ========================================================================
    {
      "<leader>rb",
      function()
        require("refactoring").refactor("Extract Block")
      end,
      mode = "n",
      desc = "Extract Block",
    },
    {
      "<leader>rbf",
      function()
        require("refactoring").refactor("Extract Block To File")
      end,
      mode = "n",
      desc = "Extract Block To File",
    },

    -- ========================================================================
    -- Debug helpers
    -- ========================================================================
    {
      "<leader>rd",
      function()
        require("refactoring").debug.printf({ below = false })
      end,
      mode = { "x", "n" },
      desc = "Debug: Print Variable",
    },
    {
      "<leader>rc",
      function()
        require("refactoring").debug.cleanup({})
      end,
      mode = "n",
      desc = "Debug: Cleanup Prints",
    },

    -- ========================================================================
    -- Telescope integration - Select refactor operation
    -- ========================================================================
    {
      "<leader>rs",
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      mode = "x",
      desc = "Select Refactor (Telescope)",
    },
  },
  opts = {
    -- Prompt for function return type (disabled for most languages)
    prompt_func_return_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
      h = false,
      hpp = false,
      cxx = false,
    },
    -- Prompt for function parameter types (disabled for most languages)
    prompt_func_param_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
      h = false,
      hpp = false,
      cxx = false,
    },
    -- Custom printf/print_var statements for debug helpers
    -- Empty tables use language defaults
    printf_statements = {},
    print_var_statements = {},
    -- Show success notification after refactoring
    show_success_message = true,
  },
  config = function(_, opts)
    local refactoring = require("refactoring")
    refactoring.setup(opts)

    -- ========================================================================
    -- Telescope integration
    -- ========================================================================
    -- Load refactoring extension for Telescope
    -- Enables <leader>rs to show available refactoring operations in a picker
    require("telescope").load_extension("refactoring")
  end,
}
