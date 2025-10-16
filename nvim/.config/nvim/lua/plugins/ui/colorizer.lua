-- ============================================================================
-- Nvim-colorizer - Preview de colores en tiempo real
-- ============================================================================
-- Muestra colores hexadecimales, RGB, HSL con el color real en tiempo real.
-- Documentación: https://github.com/NvChad/nvim-colorizer.lua
-- ============================================================================

return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    filetypes = { "*" },
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = true,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      mode = "background",
      tailwind = true,
    },
  },
}
