-- ============================================================================
-- Utilidades y helpers generales
-- ============================================================================
-- Funciones reutilizables para toda la configuración de Neovim.
-- ============================================================================

local M = {}

-- Helper: Crear keymap con opciones por defecto
-- @param mode string|table: Modo(s) de vim
-- @param lhs string: Combinación de teclas
-- @param rhs string|function: Comando o función a ejecutar
-- @param opts table: Opciones adicionales
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Helper: Crear keymap de buffer
-- @param bufnr number: Número de buffer
-- @param mode string|table: Modo(s) de vim
-- @param lhs string: Combinación de teclas
-- @param rhs string|function: Comando o función
-- @param desc string: Descripción del keymap
function M.buf_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    silent = true,
    noremap = true,
    desc = desc,
  })
end

-- Helper: Verificar si un plugin está instalado
-- @param plugin string: Nombre del plugin
-- @return boolean: true si está instalado
function M.has_plugin(plugin)
  local ok, _ = pcall(require, plugin)
  return ok
end

-- Helper: Obtener highlight de un grupo
-- @param name string: Nombre del grupo de highlight
-- @return table: Atributos del highlight
function M.get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name })
end

-- Helper: Establecer highlight
-- @param name string: Nombre del grupo
-- @param opts table: Atributos (fg, bg, bold, etc)
function M.set_hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

-- Helper: Verificar si un comando existe
-- @param cmd string: Nombre del comando
-- @return boolean: true si existe
function M.command_exists(cmd)
  return vim.fn.exists(':' .. cmd) == 2
end

-- Helper: Verificar si un ejecutable existe en el PATH
-- @param exe string: Nombre del ejecutable
-- @return boolean: true si existe
function M.executable_exists(exe)
  return vim.fn.executable(exe) == 1
end

-- Helper: Crear autocomando
-- @param event string|table: Evento(s)
-- @param opts table: Opciones del autocomando
function M.autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, opts)
end

-- Helper: Crear grupo de autocomandos
-- @param name string: Nombre del grupo
-- @param opts table: Opciones del grupo
-- @return number: ID del grupo
function M.augroup(name, opts)
  return vim.api.nvim_create_augroup(name, opts or { clear = true })
end

-- Helper: Crear comando de usuario
-- @param name string: Nombre del comando
-- @param callback function: Función a ejecutar
-- @param opts table: Opciones del comando
function M.command(name, callback, opts)
  vim.api.nvim_create_user_command(name, callback, opts or {})
end

-- Helper: Notificación
-- @param msg string: Mensaje a mostrar
-- @param level string: Nivel (info, warn, error)
-- @param opts table: Opciones adicionales
function M.notify(msg, level, opts)
  opts = opts or {}
  level = level or "info"

  local levels = {
    info = vim.log.levels.INFO,
    warn = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
  }

  vim.notify(msg, levels[level] or levels.info, opts)
end

-- Helper: Cargar módulo de forma segura
-- @param module string: Nombre del módulo
-- @return any|nil: Módulo cargado o nil si falla
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    M.notify("Failed to load module: " .. module, "error")
    return nil
  end
  return result
end

-- Helper: Merge de tablas (deep merge)
-- @param ... table: Tablas a mezclar
-- @return table: Tabla resultante
function M.merge(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for k, v in pairs(tbl) do
      if type(v) == "table" and type(result[k]) == "table" then
        result[k] = M.merge(result[k], v)
      else
        result[k] = v
      end
    end
  end
  return result
end

-- Helper: Verificar si es un directorio
-- @param path string: Ruta a verificar
-- @return boolean: true si es directorio
function M.is_directory(path)
  return vim.fn.isdirectory(path) == 1
end

-- Helper: Verificar si es un archivo
-- @param path string: Ruta a verificar
-- @return boolean: true si es archivo
function M.is_file(path)
  return vim.fn.filereadable(path) == 1
end

return M
