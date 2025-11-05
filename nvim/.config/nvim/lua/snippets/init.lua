-- Snippet loader - Carga snippets personalizados por lenguaje
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt

-- Exportar funciones helper para reutilización
local M = {}

M.s = s
M.t = t
M.i = i
M.f = f
M.c = c
M.d = d
M.fmt = fmt

-- Cargar snippets personalizados por lenguaje
function M.load()
  require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })
end

return M
