-- Test file for aerial.nvim
-- This file contains multiple symbol types to test aerial outline

local M = {}

-- Module-level constants
M.VERSION = "1.0.0"
M.MAX_ITEMS = 100

-- Class-like table
local Database = {}
Database.__index = Database

-- Constructor
function Database.new(config)
  local self = setmetatable({}, Database)
  self.config = config or {}
  self.connected = false
  return self
end

-- Methods
function Database:connect()
  print("Connecting to database...")
  self.connected = true
  return true
end

function Database:disconnect()
  print("Disconnecting from database...")
  self.connected = false
end

function Database:query(sql)
  if not self.connected then
    error("Not connected to database")
  end
  print("Executing query: " .. sql)
  return {}
end

-- Standalone functions
local function validateConfig(config)
  if not config then
    return false, "Config is nil"
  end
  return true, nil
end

local function formatError(err)
  return "[ERROR] " .. tostring(err)
end

-- Public API functions
function M.createDatabase(config)
  local valid, err = validateConfig(config)
  if not valid then
    error(formatError(err))
  end
  return Database.new(config)
end

function M.testConnection(db)
  if not db then
    return false
  end
  return db:connect()
end

-- Nested module
M.Utils = {}

function M.Utils.deepCopy(tbl)
  if type(tbl) ~= "table" then
    return tbl
  end
  local copy = {}
  for k, v in pairs(tbl) do
    copy[k] = M.Utils.deepCopy(v)
  end
  return copy
end

function M.Utils.merge(t1, t2)
  local result = M.Utils.deepCopy(t1)
  for k, v in pairs(t2) do
    result[k] = v
  end
  return result
end

-- Interface-like pattern
M.Logger = {}

function M.Logger:info(msg)
  print("[INFO] " .. msg)
end

function M.Logger:warn(msg)
  print("[WARN] " .. msg)
end

function M.Logger:error(msg)
  print("[ERROR] " .. msg)
end

function M.Logger:debug(msg)
  if self.debug_mode then
    print("[DEBUG] " .. msg)
  end
end

return M
