local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- Interface
  s("interface", fmt([[
    interface {} {{
      {}: {};
    }}
  ]], {
    i(1, "Name"),
    i(2, "property"),
    i(3, "type"),
  })),

  -- Type alias
  s("type", fmt([[
    type {} = {};
  ]], {
    i(1, "Name"),
    i(2, "string"),
  })),

  -- Enum
  s("enum", fmt([[
    enum {} {{
      {} = "{}",
    }}
  ]], {
    i(1, "Name"),
    i(2, "VALUE"),
    i(3, "value"),
  })),

  -- Function with types
  s("func", fmt([[
    function {}({}: {}): {} {{
      {}
    }}
  ]], {
    i(1, "name"),
    i(2, "param"),
    i(3, "type"),
    i(4, "void"),
    i(5, "// TODO"),
  })),

  -- Arrow function
  s("arrow", fmt([[
    const {} = ({}: {}): {} => {{
      {}
    }};
  ]], {
    i(1, "name"),
    i(2, "param"),
    i(3, "type"),
    i(4, "void"),
    i(5, "// TODO"),
  })),

  -- Async function
  s("async", fmt([[
    async function {}({}: {}): Promise<{}> {{
      {}
    }}
  ]], {
    i(1, "name"),
    i(2, "param"),
    i(3, "type"),
    i(4, "void"),
    i(5, "// TODO"),
  })),

  -- Async arrow function
  s("asyncarrow", fmt([[
    const {} = async ({}: {}): Promise<{}> => {{
      {}
    }};
  ]], {
    i(1, "name"),
    i(2, "param"),
    i(3, "type"),
    i(4, "void"),
    i(5, "// TODO"),
  })),

  -- Try-catch
  s("try", fmt([[
    try {{
      {}
    }} catch (error) {{
      console.error({}, error);
    }}
  ]], {
    i(1, "// TODO"),
    i(2, '"Error:"'),
  })),

  -- Try-catch with type guard
  s("tryguard", fmt([[
    try {{
      {}
    }} catch (error) {{
      if (error instanceof Error) {{
        console.error({}, error.message);
      }} else {{
        console.error({}, error);
      }}
    }}
  ]], {
    i(1, "// TODO"),
    i(2, '"Error:"'),
    i(3, '"Unknown error:"'),
  })),

  -- Console log
  s("log", fmt([[
    console.log("{}: ", {});
  ]], {
    i(1, "variable"),
    rep(1),
  })),

  -- Console error
  s("error", fmt([[
    console.error("{}: ", {});
  ]], {
    i(1, "variable"),
    rep(1),
  })),

  -- Console warn
  s("warn", fmt([[
    console.warn("{}: ", {});
  ]], {
    i(1, "variable"),
    rep(1),
  })),

  -- Export const
  s("export", fmt([[
    export const {} = {};
  ]], {
    i(1, "name"),
    i(2, "value"),
  })),

  -- Import statement
  s("import", fmt([[
    import {{ {} }} from "{}";
  ]], {
    i(1, "module"),
    i(2, "path"),
  })),

  -- Default import
  s("importd", fmt([[
    import {} from "{}";
  ]], {
    i(1, "module"),
    i(2, "path"),
  })),
}
