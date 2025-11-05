local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- Function declaration
  s("func", fmt([[
    function {}({}) {{
      {}
    }}
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "// TODO"),
  })),

  -- Arrow function
  s("arrow", fmt([[
    const {} = ({}) => {{
      {}
    }};
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "// TODO"),
  })),

  -- Arrow function one-liner
  s("arrowl", fmt([[
    const {} = ({}) => {};
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "value"),
  })),

  -- Async function
  s("async", fmt([[
    async function {}({}) {{
      {}
    }}
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "// TODO"),
  })),

  -- Async arrow function
  s("asyncarrow", fmt([[
    const {} = async ({}) => {{
      {}
    }};
  ]], {
    i(1, "name"),
    i(2, "params"),
    i(3, "// TODO"),
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

  -- Promise
  s("promise", fmt([[
    new Promise((resolve, reject) => {{
      {}
    }})
  ]], {
    i(1, "// TODO"),
  })),

  -- Async/await with try-catch
  s("asynctry", fmt([[
    try {{
      const {} = await {};
      {}
    }} catch (error) {{
      console.error({}, error);
    }}
  ]], {
    i(1, "result"),
    i(2, "asyncFunction()"),
    i(3, "// TODO"),
    i(4, '"Error:"'),
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

  -- Console table
  s("table", fmt([[
    console.table({});
  ]], {
    i(1, "data"),
  })),

  -- For loop
  s("for", fmt([[
    for (let {} = 0; {} < {}; {}++) {{
      {}
    }}
  ]], {
    i(1, "i"),
    rep(1),
    i(2, "array.length"),
    rep(1),
    i(3, "// TODO"),
  })),

  -- For-of loop
  s("forof", fmt([[
    for (const {} of {}) {{
      {}
    }}
  ]], {
    i(1, "item"),
    i(2, "array"),
    i(3, "// TODO"),
  })),

  -- For-in loop
  s("forin", fmt([[
    for (const {} in {}) {{
      {}
    }}
  ]], {
    i(1, "key"),
    i(2, "object"),
    i(3, "// TODO"),
  })),

  -- ForEach
  s("foreach", fmt([[
    {}.forEach(({}) => {{
      {}
    }});
  ]], {
    i(1, "array"),
    i(2, "item"),
    i(3, "// TODO"),
  })),

  -- Map
  s("map", fmt([[
    const {} = {}.map(({}) => {{
      {}
    }});
  ]], {
    i(1, "result"),
    i(2, "array"),
    i(3, "item"),
    i(4, "return item"),
  })),

  -- Filter
  s("filter", fmt([[
    const {} = {}.filter(({}) => {{
      {}
    }});
  ]], {
    i(1, "result"),
    i(2, "array"),
    i(3, "item"),
    i(4, "return true"),
  })),

  -- Reduce
  s("reduce", fmt([[
    const {} = {}.reduce((acc, {}) => {{
      {}
    }}, {});
  ]], {
    i(1, "result"),
    i(2, "array"),
    i(3, "item"),
    i(4, "return acc"),
    i(5, "initialValue"),
  })),

  -- Class
  s("class", fmt([[
    class {} {{
      constructor({}) {{
        {}
      }}

      {}() {{
        {}
      }}
    }}
  ]], {
    i(1, "ClassName"),
    i(2, "params"),
    i(3, "// TODO"),
    i(4, "method"),
    i(5, "// TODO"),
  })),

  -- Export const
  s("export", fmt([[
    export const {} = {};
  ]], {
    i(1, "name"),
    i(2, "value"),
  })),

  -- Export default
  s("exportd", fmt([[
    export default {};
  ]], {
    i(1, "value"),
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

  -- Destructuring
  s("dest", fmt([[
    const {{ {} }} = {};
  ]], {
    i(1, "property"),
    i(2, "object"),
  })),

  -- Array destructuring
  s("desta", fmt([[
    const [{}, {}] = {};
  ]], {
    i(1, "first"),
    i(2, "second"),
    i(3, "array"),
  })),

  -- Template literal
  s("temp", fmt([[
    `${{{}}} {}`
  ]], {
    i(1, "variable"),
    i(2, "text"),
  })),

  -- Object method shorthand
  s("method", fmt([[
    {}({}) {{
      {}
    }},
  ]], {
    i(1, "methodName"),
    i(2, "params"),
    i(3, "// TODO"),
  })),
}
