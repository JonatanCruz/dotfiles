-- ============================================================================
-- Iconos centralizados para toda la configuración de Neovim
-- ============================================================================
-- Este archivo contiene todos los iconos Nerd Font usados en la configuración.
-- Centralizar los iconos facilita su actualización y mantiene consistencia.
-- ============================================================================

local M = {}

-- Iconos de diagnósticos LSP
M.diagnostics = {
  error = "",
  warn = "",
  hint = "",
  info = "",
  other = "",
}

-- Iconos de Git
M.git = {
  added = "",
  modified = "",
  removed = "",
  renamed = "➜",
  untracked = "★",
  ignored = "◌",
  unstaged = "✗",
  staged = "✓",
  conflict = "",
  branch = "",
  diff = "",
}

-- Iconos de tipos de archivos
M.file = {
  folder_closed = "",
  folder_open = "",
  folder_empty = "",
  file = "",
  symlink = "",
  modified = "●",
}

-- Iconos de UI
M.ui = {
  lock = "",
  circle = "●",
  big_circle = "",
  big_unf_circle = "",
  close = "",
  new_file = "",
  search = "",
  lightbulb = "",
  project = "",
  dashboard = "",
  history = "",
  comment = "",
  bug = "",
  code = "",
  telescope = "󰍉",
  gear = "",
  package = "󰏖",
  list = "",
  sign_in = "",
  check = "",
  fire = "",
  note = "",
  bookmark = "",
  pencil = "󰏫",
  chevron_right = "",
  table = "",
  calendar = "",
}

-- Iconos de separadores
M.separators = {
  breadcrumb = "»",
  arrow = "➜",
  pipe = "|",
  slash = "/",
  double_arrow = "»",
}

-- Iconos para which-key
M.whichkey = {
  buffer = "󰓩",
  search = "󰍉",
  git = "󰊢",
  hunk = "",
  lint = "󰁨",
  no_highlight = "󰹾",
  packages = "󰏖",
  reload = "󰑓",
  split = "󰯌",
  toggle = "󰔡",
  diagnostics = "󰙅",
}

-- Iconos para todo-comments
M.todo = {
  FIX = " ",
  TODO = " ",
  HACK = " ",
  WARN = " ",
  PERF = " ",
  NOTE = " ",
}

-- Iconos de LSP kinds (para autocompletado)
M.kind = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

return M
