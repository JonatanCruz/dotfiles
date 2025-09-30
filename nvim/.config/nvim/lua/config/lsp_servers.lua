-- Este archivo contiene la lista de LSPs que Mason debe instalar.
-- Para añadir un nuevo LSP:
-- 1. Búscalo en Mason con `:Mason`.
-- 2. Copia su nombre de paquete (ej. 'pyright').
-- 3. Añádelo como un string a esta tabla.

return {
  -- === Desarrollo Web ===
  "html",
  "cssls",
  "tailwindcss",
  "ts_ls",
  "emmet_ls",

  -- === Backend ===
  "lua_ls",
  -- "pyright",         -- Python
  -- "gopls",           -- Go
  -- "rust_analyzer",   -- Rust

  -- === DevOps / Herramientas ===
  -- "bashls",          -- Bash
  -- "dockerls",        -- Dockerfile
  -- "yamlls",          -- YAML

  -- === Bases de Datos ===
  -- "sqlls",           -- SQL
}
