-- ============================================================================
-- WEZTERM CONFIGURATION
-- ============================================================================
-- Configuración optimizada para desarrollo de software en macOS

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ============================================================================
-- APARIENCIA Y TEMA
-- ============================================================================

config.color_scheme = "Catppuccin Frappe"
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold", style = "Italic" })
config.font_size = 14.5

-- Transparencia y blur
config.window_background_opacity = 0.6
config.macos_window_background_blur = 20

-- Estilo de ventana
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 0,
}

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- ============================================================================
-- TAB BAR PERSONALIZADO
-- ============================================================================

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- Colores personalizados para la tab bar
config.colors = {
  tab_bar = {
    background = "#303446",
    active_tab = {
      bg_color = "#8caaee",
      fg_color = "#232634",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#414559",
      fg_color = "#c6d0f5",
    },
    inactive_tab_hover = {
      bg_color = "#51576d",
      fg_color = "#c6d0f5",
    },
    new_tab = {
      bg_color = "#303446",
      fg_color = "#c6d0f5",
    },
  },
}

-- ============================================================================
-- RENDIMIENTO Y OPTIMIZACIÓN
-- ============================================================================

config.max_fps = 120
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.animation_fps = 60
config.scrollback_lines = 10000

-- ============================================================================
-- COMPORTAMIENTO
-- ============================================================================

-- Confirmar antes de cerrar con múltiples panes
config.window_close_confirmation = "AlwaysPrompt"

-- Scroll automático al escribir
config.alternate_buffer_wheel_scroll_speed = 1

-- Click derecho pega desde clipboard
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}

-- ============================================================================
-- KEYBINDINGS PARA DESARROLLO
-- ============================================================================

config.keys = {
  -- ========================================
  -- GESTIÓN DE VENTANAS Y PANES
  -- ========================================

  -- Toggle fullscreen
  {
    key = "f",
    mods = "CTRL",
    action = act.ToggleFullScreen,
  },

  -- Split horizontal (como tmux)
  {
    key = "|",
    mods = "CMD|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },

  -- Split vertical (como tmux)
  {
    key = "_",
    mods = "CMD|SHIFT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Cerrar pane actual
  {
    key = "w",
    mods = "CMD",
    action = act.CloseCurrentPane({ confirm = true }),
  },

  -- Navegación entre panes (estilo vim)
  {
    key = "h",
    mods = "CMD",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "j",
    mods = "CMD",
    action = act.ActivatePaneDirection("Down"),
  },
  {
    key = "k",
    mods = "CMD",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "l",
    mods = "CMD",
    action = act.ActivatePaneDirection("Right"),
  },

  -- Redimensionar panes
  {
    key = "LeftArrow",
    mods = "CMD|SHIFT",
    action = act.AdjustPaneSize({ "Left", 5 }),
  },
  {
    key = "RightArrow",
    mods = "CMD|SHIFT",
    action = act.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "UpArrow",
    mods = "CMD|SHIFT",
    action = act.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "DownArrow",
    mods = "CMD|SHIFT",
    action = act.AdjustPaneSize({ "Down", 5 }),
  },

  -- ========================================
  -- GESTIÓN DE TABS
  -- ========================================

  -- Nueva tab
  {
    key = "t",
    mods = "CMD",
    action = act.SpawnTab("CurrentPaneDomain"),
  },

  -- Cerrar tab
  {
    key = "w",
    mods = "CMD|SHIFT",
    action = act.CloseCurrentTab({ confirm = true }),
  },

  -- Navegar entre tabs
  {
    key = "[",
    mods = "CMD",
    action = act.ActivateTabRelative(-1),
  },
  {
    key = "]",
    mods = "CMD",
    action = act.ActivateTabRelative(1),
  },

  -- Mover tabs
  {
    key = "[",
    mods = "CMD|SHIFT",
    action = act.MoveTabRelative(-1),
  },
  {
    key = "]",
    mods = "CMD|SHIFT",
    action = act.MoveTabRelative(1),
  },

  -- Acceso rápido a tabs (1-9)
  {
    key = "1",
    mods = "CMD",
    action = act.ActivateTab(0),
  },
  {
    key = "2",
    mods = "CMD",
    action = act.ActivateTab(1),
  },
  {
    key = "3",
    mods = "CMD",
    action = act.ActivateTab(2),
  },
  {
    key = "4",
    mods = "CMD",
    action = act.ActivateTab(3),
  },
  {
    key = "5",
    mods = "CMD",
    action = act.ActivateTab(4),
  },
  {
    key = "6",
    mods = "CMD",
    action = act.ActivateTab(5),
  },
  {
    key = "7",
    mods = "CMD",
    action = act.ActivateTab(6),
  },
  {
    key = "8",
    mods = "CMD",
    action = act.ActivateTab(7),
  },
  {
    key = "9",
    mods = "CMD",
    action = act.ActivateTab(-1),
  },

  -- ========================================
  -- UTILIDADES DE DESARROLLO
  -- ========================================

  -- Limpiar terminal
  {
    key = "k",
    mods = "CMD",
    action = act.ClearScrollback("ScrollbackAndViewport"),
  },

  -- Buscar en terminal
  {
    key = "f",
    mods = "CMD",
    action = act.Search("CurrentSelectionOrEmptyString"),
  },

  -- Quick select (URLs, hashes, paths)
  {
    key = "Space",
    mods = "CMD|SHIFT",
    action = act.QuickSelect,
  },

  -- Copiar al portapapeles
  {
    key = "c",
    mods = "CMD",
    action = act.CopyTo("Clipboard"),
  },

  -- Pegar desde portapapeles
  {
    key = "v",
    mods = "CMD",
    action = act.PasteFrom("Clipboard"),
  },

  -- Abrir launcher de comandos
  {
    key = "p",
    mods = "CMD|SHIFT",
    action = act.ActivateCommandPalette,
  },

  -- Zoom
  {
    key = "=",
    mods = "CMD",
    action = act.IncreaseFontSize,
  },
  {
    key = "-",
    mods = "CMD",
    action = act.DecreaseFontSize,
  },
  {
    key = "0",
    mods = "CMD",
    action = act.ResetFontSize,
  },

  -- Modo de selección de panes (útil con muchos panes)
  {
    key = "Enter",
    mods = "CMD",
    action = act.ActivateCopyMode,
  },

  -- Renombrar tab actual
  {
    key = "r",
    mods = "CMD|SHIFT",
    action = act.PromptInputLine({
      description = "Ingresa el nuevo nombre para esta tab:",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

-- ============================================================================
-- HYPERLINK RULES (Detección mejorada de URLs y paths)
-- ============================================================================

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Detectar URLs de GitHub/GitLab issues y PRs
table.insert(config.hyperlink_rules, {
  regex = [[\b[a-zA-Z0-9-]+/[a-zA-Z0-9-]+#\d+\b]],
  format = "https://github.com/$0",
})

-- Detectar paths de archivos absolutos
table.insert(config.hyperlink_rules, {
  regex = [[/\S+]],
  format = "$0",
})

-- Detectar localhost URLs
table.insert(config.hyperlink_rules, {
  regex = [[\blocalhost:\d+\b]],
  format = "http://$0",
})

-- ============================================================================
-- QUICK SELECT PATTERNS (Para desarrollo)
-- ============================================================================

config.quick_select_patterns = {
  -- Git commit hashes
  "[0-9a-f]{7,40}",
  -- UUIDs
  "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
  -- IP addresses
  "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}",
  -- Kubernetes pods
  "[a-z0-9-]+-[a-z0-9]+-[a-z0-9]+",
  -- Semantic versions
  "v?\\d+\\.\\d+\\.\\d+",
  -- Hex colors
  "#[0-9a-fA-F]{6}",
  -- Docker container IDs
  "[0-9a-f]{12}",
}

-- ============================================================================
-- WORKSPACES (Proyectos de desarrollo)
-- ============================================================================

-- Workspace switcher
wezterm.on("update-right-status", function(window, pane)
  local workspace = window:active_workspace()
  local time = wezterm.strftime("%H:%M")

  -- Obtener el directorio actual
  local cwd = pane:get_current_working_dir()
  local cwd_display = ""
  if cwd then
    cwd_display = " " .. cwd.file_path:match("([^/]+)/?$")
  end

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#8caaee" } },
    { Text = " " .. workspace .. cwd_display .. " | " .. time .. " " },
  }))
end)

-- ============================================================================
-- ZEN MODE (Integración con Neovim)
-- ============================================================================

wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while number_value > 0 do
        window:perform_action(act.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(act.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

-- ============================================================================
-- FORMATO DE TABS (Mostrar índice y título)
-- ============================================================================

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title

  -- Si no hay título personalizado, usar el título del pane
  if title and #title > 0 then
    title = title
  else
    title = tab.active_pane.title
  end

  -- Obtener el directorio del pane
  local cwd = tab.active_pane.current_working_dir
  if cwd then
    local dir = cwd.file_path:match("([^/]+)/?$")
    if dir then
      title = dir
    end
  end

  -- Limitar longitud del título
  if #title > 16 then
    title = title:sub(1, 13) .. "..."
  end

  local index = tab.tab_index + 1

  return {
    { Text = " " .. index .. ": " .. title .. " " },
  }
end)

-- ============================================================================
-- RETURN CONFIGURATION
-- ============================================================================

return config
