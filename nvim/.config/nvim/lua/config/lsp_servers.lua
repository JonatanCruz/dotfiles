-- ============================================================================
-- SERVIDORES LSP
-- ============================================================================
-- Lista de Language Servers que Mason instalará automáticamente
--
-- CÓMO AÑADIR UN NUEVO LSP:
-- 1. Abre Mason con el comando: :Mason
-- 2. Busca el servidor que necesitas
-- 3. Copia su nombre exacto (ej. 'pyright', 'gopls', etc.)
-- 4. Añádelo a la tabla correspondiente abajo
-- 5. Guarda el archivo - Lazy recargará automáticamente
-- 6. Cierra y vuelve a abrir Neovim para que Mason lo instale
--
-- ============================================================================

return {
  -- ============================================================================
  -- DESARROLLO WEB FRONTEND
  -- ============================================================================
  "html",           -- HTML
  "cssls",          -- CSS
  "tailwindcss",    -- Tailwind CSS
  "ts_ls",          -- TypeScript/JavaScript
  "emmet_ls",       -- Emmet (autocompletado HTML/CSS)

  -- ============================================================================
  -- LENGUAJES DE PROGRAMACIÓN
  -- ============================================================================
  "lua_ls",         -- Lua (para configuración de Neovim)
  -- "pyright",     -- Python
  -- "gopls",       -- Go
  -- "rust_analyzer", -- Rust
  -- "clangd",      -- C/C++
  -- "jdtls",       -- Java

  -- ============================================================================
  -- BACKEND Y FRAMEWORKS
  -- ============================================================================
  -- "volar",       -- Vue.js
  -- "svelte",      -- Svelte
  -- "astro",       -- Astro

  -- ============================================================================
  -- DEVOPS Y HERRAMIENTAS
  -- ============================================================================
  -- "bashls",      -- Bash
  -- "dockerls",    -- Dockerfile
  -- "docker_compose_language_service", -- Docker Compose
  -- "yamlls",      -- YAML
  -- "jsonls",      -- JSON

  -- ============================================================================
  -- BASES DE DATOS
  -- ============================================================================
  -- "sqlls",       -- SQL

  -- ============================================================================
  -- MARKUP Y DOCUMENTACIÓN
  -- ============================================================================
  -- "marksman",    -- Markdown
}
