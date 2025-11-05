-- ============================================================================
-- Neogen - Generación automática de documentación
-- ============================================================================
-- Genera docstrings/JSDoc/TSDoc automáticamente con treesitter
-- Documentación: https://github.com/danymat/neogen
-- ============================================================================

return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",

  -- Lazy loading con keybindings trigger
  keys = {
    -- <leader>n → New/Generate Docs
    {
      "<leader>nf",
      function()
        require("neogen").generate({ type = "func" })
      end,
      desc = "Generate Function Docs",
    },
    {
      "<leader>nc",
      function()
        require("neogen").generate({ type = "class" })
      end,
      desc = "Generate Class Docs",
    },
    {
      "<leader>nt",
      function()
        require("neogen").generate({ type = "type" })
      end,
      desc = "Generate Type Docs",
    },
    {
      "<leader>nF",
      function()
        require("neogen").generate({ type = "file" })
      end,
      desc = "Generate File Docs",
    },
    {
      "<leader>ng",
      function()
        require("neogen").generate()
      end,
      desc = "Generate Docs (auto-detect)",
    },
  },

  opts = {
    -- Activar generación automática
    enabled = true,

    -- Posicionar cursor después del comentario para editar
    input_after_comment = true,

    -- Integración con LuaSnip para navegación entre placeholders
    snippet_engine = "luasnip",

    -- Configuración por lenguaje
    languages = {
      -- TypeScript (TSDoc)
      typescript = {
        template = {
          annotation_convention = "tsdoc",
        },
      },

      -- JavaScript (JSDoc)
      javascript = {
        template = {
          annotation_convention = "jsdoc",
        },
      },

      -- TypeScript React (TSDoc)
      typescriptreact = {
        template = {
          annotation_convention = "tsdoc",
        },
      },

      -- JavaScript React (JSDoc)
      javascriptreact = {
        template = {
          annotation_convention = "jsdoc",
        },
      },

      -- Lua (LDoc)
      lua = {
        template = {
          annotation_convention = "ldoc",
        },
      },

      -- Python (Google Docstrings)
      python = {
        template = {
          annotation_convention = "google_docstrings",
        },
      },

      -- Rust (Rustdoc)
      rust = {
        template = {
          annotation_convention = "rustdoc",
        },
      },

      -- Go (Godoc)
      go = {
        template = {
          annotation_convention = "godoc",
        },
      },

      -- C/C++ (Doxygen)
      c = {
        template = {
          annotation_convention = "doxygen",
        },
      },

      cpp = {
        template = {
          annotation_convention = "doxygen",
        },
      },

      -- Java (Javadoc)
      java = {
        template = {
          annotation_convention = "javadoc",
        },
      },

      -- PHP (PHPDoc)
      php = {
        template = {
          annotation_convention = "phpdoc",
        },
      },

      -- Ruby (YARD)
      ruby = {
        template = {
          annotation_convention = "rdoc",
        },
      },

      -- Shell (Google Shell Style)
      sh = {
        template = {
          annotation_convention = "google_bash",
        },
      },
    },

    -- Placeholders para completar (navegables con Tab en LuaSnip)
    placeholders_text = {
      ["description"] = "[TODO: description]",
      ["tparam"] = "[TODO: parameter]",
      ["parameter"] = "[TODO: parameter]",
      ["return"] = "[TODO: return value]",
      ["class"] = "[TODO: class description]",
      ["throw"] = "[TODO: throws]",
      ["varargs"] = "[TODO: varargs]",
      ["type"] = "[TODO: type]",
      ["attribute"] = "[TODO: attribute]",
      ["args"] = "[TODO: args]",
      ["kwargs"] = "[TODO: kwargs]",
    },

    -- Highlight para placeholders (DiagnosticHint = color azul/cyan)
    placeholders_hl = "DiagnosticHint",
  },

  config = function(_, opts)
    require("neogen").setup(opts)

    -- Integración opcional con WhichKey si está disponible
    local has_which_key, wk = pcall(require, "which-key")
    if has_which_key then
      wk.add({
        { "<leader>n", group = "New/Generate Docs", icon = "󰏫" },
      })
    end
  end,
}
