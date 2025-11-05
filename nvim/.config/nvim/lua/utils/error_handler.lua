local M = {}

--- Safe require with error notification
--- @param module string Module name to require
--- @param fallback any? Optional fallback value if require fails
--- @return any|nil Module or fallback
function M.safe_require(module, fallback)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(
      string.format("Failed to load module '%s': %s", module, result),
      vim.log.levels.ERROR,
      { title = "Module Load Error" }
    )
    return fallback
  end
  return result
end

--- Try-catch wrapper for functions
--- @param fn function Function to execute
--- @param error_handler function? Optional error handler
--- @return boolean, any Success status and result or error
function M.try(fn, error_handler)
  local ok, result = pcall(fn)
  if not ok then
    if error_handler then
      error_handler(result)
    else
      vim.notify(
        string.format("Error: %s", result),
        vim.log.levels.ERROR
      )
    end
  end
  return ok, result
end

--- Safe call with default value on error
--- @param fn function Function to execute
--- @param default any Default value if function fails
--- @return any Result or default
function M.safe_call(fn, default)
  local ok, result = pcall(fn)
  return ok and result or default
end

return M
