local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
  -- Functional Component
  s("fc", fmt([[
    import {{ FC }} from 'react';

    interface {}Props {{
      {}
    }}

    export const {}: FC<{}Props> = ({{ {} }}) => {{
      return (
        <div>
          {}
        </div>
      );
    }};
  ]], {
    i(1, "Component"),
    i(2, "// props"),
    rep(1),
    rep(1),
    i(3, "props"),
    i(4, "{/* TODO */}"),
  })),

  -- Functional Component with children
  s("fcc", fmt([[
    import {{ FC, ReactNode }} from 'react';

    interface {}Props {{
      children: ReactNode;
      {}
    }}

    export const {}: FC<{}Props> = ({{ children, {} }}) => {{
      return (
        <div>
          {{children}}
        </div>
      );
    }};
  ]], {
    i(1, "Component"),
    i(2, "// props"),
    rep(1),
    rep(1),
    i(3, "props"),
  })),

  -- useState
  s("state", fmt([[
    const [{}, set{}] = useState<{}>({});
  ]], {
    i(1, "value"),
    i(2, "Value"),
    i(3, "string"),
    i(4, '""'),
  })),

  -- useEffect
  s("effect", fmt([[
    useEffect(() => {{
      {}
    }}, [{}]);
  ]], {
    i(1, "// TODO"),
    i(2, "deps"),
  })),

  -- useEffect with cleanup
  s("effectclean", fmt([[
    useEffect(() => {{
      {}

      return () => {{
        {}
      }};
    }}, [{}]);
  ]], {
    i(1, "// Setup"),
    i(2, "// Cleanup"),
    i(3, "deps"),
  })),

  -- useCallback
  s("callback", fmt([[
    const {} = useCallback(() => {{
      {}
    }}, [{}]);
  ]], {
    i(1, "handleClick"),
    i(2, "// TODO"),
    i(3, "deps"),
  })),

  -- useCallback with params
  s("callbackp", fmt([[
    const {} = useCallback(({}: {}) => {{
      {}
    }}, [{}]);
  ]], {
    i(1, "handleClick"),
    i(2, "param"),
    i(3, "type"),
    i(4, "// TODO"),
    i(5, "deps"),
  })),

  -- useMemo
  s("memo", fmt([[
    const {} = useMemo(() => {{
      return {};
    }}, [{}]);
  ]], {
    i(1, "memoizedValue"),
    i(2, "value"),
    i(3, "deps"),
  })),

  -- useRef
  s("ref", fmt([[
    const {} = useRef<{}>({});
  ]], {
    i(1, "ref"),
    i(2, "HTMLDivElement | null"),
    i(3, "null"),
  })),

  -- useContext
  s("context", fmt([[
    const {} = useContext({});
  ]], {
    i(1, "context"),
    i(2, "Context"),
  })),

  -- Custom Hook
  s("hook", fmt([[
    import {{ useState, useEffect }} from 'react';

    export const use{} = () => {{
      const [{}, set{}] = useState<{}>({});

      useEffect(() => {{
        {}
      }}, [{}]);

      return {{ {}, set{} }};
    }};
  ]], {
    i(1, "CustomHook"),
    i(2, "value"),
    i(3, "Value"),
    i(4, "string"),
    i(5, '""'),
    i(6, "// TODO"),
    i(7, "deps"),
    rep(2),
    rep(3),
  })),

  -- Context Provider
  s("provider", fmt([[
    import {{ createContext, useContext, ReactNode, FC }} from 'react';

    interface {}ContextType {{
      {}
    }}

    const {}Context = createContext<{}ContextType | undefined>(undefined);

    interface {}ProviderProps {{
      children: ReactNode;
    }}

    export const {}Provider: FC<{}ProviderProps> = ({{ children }}) => {{
      {}

      const value: {}ContextType = {{
        {}
      }};

      return (
        <{}Context.Provider value={{value}}>
          {{children}}
        </{}Context.Provider>
      );
    }};

    export const use{} = () => {{
      const context = useContext({}Context);
      if (context === undefined) {{
        throw new Error('use{} must be used within a {}Provider');
      }}
      return context;
    }};
  ]], {
    i(1, "My"),
    i(2, "// properties"),
    rep(1),
    rep(1),
    rep(1),
    rep(1),
    rep(1),
    i(3, "// state and logic"),
    rep(1),
    i(4, "// value object"),
    rep(1),
    rep(1),
    rep(1),
    rep(1),
    rep(1),
    rep(1),
  })),

  -- Import React
  s("imr", fmt([[
    import {{ {} }} from 'react';
  ]], {
    i(1, "useState, useEffect"),
  })),

  -- Import React default
  s("imrd", fmt([[
    import React from 'react';
  ]], {})),

  -- Component Props
  s("props", fmt([[
    interface {}Props {{
      {}
    }}
  ]], {
    i(1, "Component"),
    i(2, "// props"),
  })),
}
