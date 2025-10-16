-- ============================================================================
-- Helpers de colores y paleta de Catppuccin Mocha
-- ============================================================================
-- Este archivo centraliza los colores usados en toda la configuración.
-- Facilita cambiar el tema y mantener consistencia de colores.
-- ============================================================================

local M = {}

-- Paleta de colores Catppuccin Mocha
-- https://github.com/catppuccin/catppuccin#-palette
M.catppuccin = {
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  subtext1 = "#bac2de",
  subtext0 = "#a6adc8",
  overlay2 = "#9399b2",
  overlay1 = "#7f849c",
  overlay0 = "#6c7086",
  surface2 = "#585b70",
  surface1 = "#45475a",
  surface0 = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
}

-- Alias para colores comúnmente usados
M.primary = M.catppuccin.blue
M.secondary = M.catppuccin.pink
M.accent = M.catppuccin.mauve
M.bg = M.catppuccin.base
M.fg = M.catppuccin.text
M.comment = M.catppuccin.overlay0

-- Colores para diagnósticos
M.diagnostic = {
  error = M.catppuccin.red,
  warn = M.catppuccin.yellow,
  info = M.catppuccin.blue,
  hint = M.catppuccin.teal,
}

-- Colores para Git
M.git_colors = {
  add = M.catppuccin.green,
  change = M.catppuccin.yellow,
  delete = M.catppuccin.red,
}

-- Helper: Convertir hex a RGB
-- @param hex string: Color en formato hex (#RRGGBB)
-- @return table: {r, g, b} valores entre 0-255
function M.hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
  }
end

-- Helper: Crear color con transparencia
-- @param hex string: Color en formato hex
-- @param alpha number: Transparencia (0.0 - 1.0)
-- @return string: Color en formato rgba
function M.with_alpha(hex, alpha)
  local rgb = M.hex_to_rgb(hex)
  return string.format("rgba(%d, %d, %d, %.2f)", rgb.r, rgb.g, rgb.b, alpha)
end

-- Helper: Mezclar dos colores
-- @param color1 string: Primer color hex
-- @param color2 string: Segundo color hex
-- @param weight number: Peso del primer color (0.0 - 1.0)
-- @return string: Color mezclado en hex
function M.blend(color1, color2, weight)
  local rgb1 = M.hex_to_rgb(color1)
  local rgb2 = M.hex_to_rgb(color2)

  local r = math.floor(rgb1.r * weight + rgb2.r * (1 - weight))
  local g = math.floor(rgb1.g * weight + rgb2.g * (1 - weight))
  local b = math.floor(rgb1.b * weight + rgb2.b * (1 - weight))

  return string.format("#%02x%02x%02x", r, g, b)
end

return M
