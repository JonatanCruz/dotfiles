-- ============================================================================
-- Helpers de transparencia
-- ============================================================================
-- Funciones para aplicar transparencia de forma consistente a todos los plugins.
-- ============================================================================

local M = {}

-- Lista completa de highlight groups que deben ser transparentes
M.transparent_groups = {
  -- Ventanas principales
  "Normal",
  "NormalNC",
  "SignColumn",
  "EndOfBuffer",

  -- Ventanas flotantes
  "NormalFloat",
  "FloatBorder",
  "FloatTitle",

  -- Línea de cursor
  "CursorLine",
  "CursorLineNr",
  "CursorColumn",

  -- Números de línea
  "LineNr",
  "LineNrAbove",
  "LineNrBelow",

  -- Folds
  "Folded",
  "FoldColumn",

  -- Statusline y Tabline
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "TabLineSel",

  -- Pmenu (menú de completado)
  "Pmenu",
  "PmenuSbar",
  "PmenuThumb",

  -- Ventanas de división
  "WinSeparator",
  "VertSplit",

  -- Nvim-tree
  "NvimTreeNormal",
  "NvimTreeNormalFloat",
  "NvimTreeNormalNC",
  "NvimTreeEndOfBuffer",
  "NvimTreeWinSeparator",
  "NvimTreeCursorLine",

  -- Telescope
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "TelescopePromptTitle",
  "TelescopePreviewNormal",
  "TelescopePreviewBorder",
  "TelescopePreviewTitle",
  "TelescopeResultsNormal",
  "TelescopeResultsBorder",
  "TelescopeResultsTitle",

  -- Which-key
  "WhichKeyFloat",
  "WhichKeyBorder",
  "WhichKeyNormal",

  -- Alpha (dashboard)
  "AlphaHeader",
  "AlphaButtons",
  "AlphaShortcut",
  "AlphaFooter",

  -- Lazy.nvim
  "LazyNormal",
  "LazyButton",
  "LazyButtonActive",

  -- Mason
  "MasonNormal",
  "MasonHeader",

  -- Notify
  "NotifyBackground",

  -- Trouble
  "TroubleNormal",

  -- nvim-cmp
  "CmpNormal",
  "CmpBorder",
  "CmpDocNormal",
  "CmpDocBorder",

  -- LSP
  "LspInfoBorder",

  -- Noice (si se usa en el futuro)
  "NoicePopup",
  "NoicePopupBorder",
}

-- Aplicar transparencia a todos los grupos
-- @param exceptions table: Grupos a excluir (opcional)
function M.apply_transparency(exceptions)
  exceptions = exceptions or {}
  local exception_set = {}
  for _, group in ipairs(exceptions) do
    exception_set[group] = true
  end

  for _, group in ipairs(M.transparent_groups) do
    if not exception_set[group] then
      -- Intentar obtener el highlight actual
      local hl = vim.api.nvim_get_hl(0, { name = group })

      -- Si el grupo existe o queremos forzar su creación
      if hl or vim.fn.hlexists(group) == 1 then
        -- Mantener foreground si existe, pero eliminar background
        vim.api.nvim_set_hl(0, group, {
          fg = hl.fg,
          bg = "none",
          sp = hl.sp,
          bold = hl.bold,
          italic = hl.italic,
          underline = hl.underline,
          undercurl = hl.undercurl,
          strikethrough = hl.strikethrough,
        })
      else
        -- Si no existe, crear con solo bg transparente
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
    end
  end
end

-- Aplicar transparencia específica a un grupo
-- @param group string: Nombre del grupo
-- @param opts table: Opciones adicionales (fg, bold, etc)
function M.set_transparent(group, opts)
  opts = opts or {}
  opts.bg = "none"
  vim.api.nvim_set_hl(0, group, opts)
end

-- Link a otro grupo manteniendo transparencia
-- @param from string: Grupo origen
-- @param to string: Grupo destino
function M.link_transparent(from, to)
  vim.api.nvim_set_hl(0, from, { link = to })
end

-- Aplicar transparencia después de cambiar colorscheme
function M.setup_autocmd()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      M.apply_transparency()
    end,
    desc = "Aplicar transparencia después de cambiar colorscheme",
  })
end

return M
