local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- Neovim plugin spec (lazy.nvim)
  s("plugin", fmt([[
    {{
      "{}",
      dependencies = {{ {} }},
      event = "{}",
      config = function()
        require("{}").setup({{
          {}
        }})
      end,
    }}
  ]], {
    i(1, "author/plugin"),
    i(2, '"dependency"'),
    i(3, "VeryLazy"),
    i(4, "plugin"),
    i(5, "-- opts"),
  })),

  -- Simple plugin spec
  s("pluginsimple", fmt([[
    {{
      "{}",
      event = "{}",
    }}
  ]], {
    i(1, "author/plugin"),
    i(2, "VeryLazy"),
  })),

  -- Function with annotation
  s("func", fmt([[
    --- {}
    --- @param {} {} {}
    --- @return {} {}
    function {}({})
      {}
    end
  ]], {
    i(1, "Description"),
    i(2, "param"),
    i(3, "type"),
    i(4, "description"),
    i(5, "type"),
    i(6, "description"),
    i(7, "name"),
    rep(2),
    i(8, "-- TODO"),
  })),

  -- Local function
  s("lfunc", fmt([[
    local function {}({})
      {}
    end
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "-- TODO"),
  })),

  -- Autocommand
  s("autocmd", fmt([[
    vim.api.nvim_create_autocmd("{}", {{
      pattern = "{}",
      callback = function()
        {}
      end,
    }})
  ]], {
    i(1, "BufWritePre"),
    i(2, "*"),
    i(3, "-- TODO"),
  })),

  -- Autocommand group
  s("augroup", fmt([[
    local augroup = vim.api.nvim_create_augroup("{}", {{ clear = true }})
    vim.api.nvim_create_autocmd("{}", {{
      group = augroup,
      pattern = "{}",
      callback = function()
        {}
      end,
    }})
  ]], {
    i(1, "MyGroup"),
    i(2, "BufWritePre"),
    i(3, "*"),
    i(4, "-- TODO"),
  })),

  -- Keymap
  s("keymap", fmt([[
    vim.keymap.set("{}", "{}", "{}", {{ desc = "{}" }})
  ]], {
    i(1, "n"),
    i(2, "<leader>"),
    i(3, "<cmd><cr>"),
    i(4, "Description"),
  })),

  -- Keymap with function
  s("keymapf", fmt([[
    vim.keymap.set("{}", "{}", function()
      {}
    end, {{ desc = "{}" }})
  ]], {
    i(1, "n"),
    i(2, "<leader>"),
    i(3, "-- TODO"),
    i(4, "Description"),
  })),

  -- Buffer keymap
  s("bkeymap", fmt([[
    vim.keymap.set("{}", "{}", "{}", {{ buffer = {}, desc = "{}" }})
  ]], {
    i(1, "n"),
    i(2, "<leader>"),
    i(3, "<cmd><cr>"),
    i(4, "bufnr"),
    i(5, "Description"),
  })),

  -- Vim option
  s("opt", fmt([[
    vim.opt.{} = {}
  ]], {
    i(1, "option"),
    i(2, "value"),
  })),

  -- Vim global
  s("g", fmt([[
    vim.g.{} = {}
  ]], {
    i(1, "variable"),
    i(2, "value"),
  })),

  -- Module table
  s("module", fmt([[
    local M = {{}}

    {}

    return M
  ]], {
    i(1, "-- Functions"),
  })),

  -- Require statement
  s("req", fmt([[
    local {} = require("{}")
  ]], {
    i(1, "module"),
    rep(1),
  })),

  -- Protected require
  s("preq", fmt([[
    local ok, {} = pcall(require, "{}")
    if not ok then
      return
    end
  ]], {
    i(1, "module"),
    rep(1),
  })),

  -- Print statement
  s("print", fmt([[
    print("{}: ", vim.inspect({}))
  ]], {
    i(1, "variable"),
    rep(1),
  })),

  -- Vim notify
  s("notify", fmt([[
    vim.notify("{}", vim.log.levels.{})
  ]], {
    i(1, "Message"),
    i(2, "INFO"),
  })),

  -- If statement
  s("if", fmt([[
    if {} then
      {}
    end
  ]], {
    i(1, "condition"),
    i(2, "-- TODO"),
  })),

  -- If-else statement
  s("ifelse", fmt([[
    if {} then
      {}
    else
      {}
    end
  ]], {
    i(1, "condition"),
    i(2, "-- TODO"),
    i(3, "-- TODO"),
  })),

  -- For loop
  s("for", fmt([[
    for {}, {} in {}({}) do
      {}
    end
  ]], {
    i(1, "i"),
    i(2, "v"),
    i(3, "ipairs"),
    i(4, "table"),
    i(5, "-- TODO"),
  })),

  -- For numeric loop
  s("fori", fmt([[
    for {} = {}, {} do
      {}
    end
  ]], {
    i(1, "i"),
    i(2, "1"),
    i(3, "10"),
    i(4, "-- TODO"),
  })),
}
