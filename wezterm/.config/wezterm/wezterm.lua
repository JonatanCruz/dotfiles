-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "Nord (Gogh)"
config.color_scheme = "Catppuccin Frappe"

-- Custom Config
config.enable_tab_bar = false
config.font_size = 14.5
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold", style = "Italic" })
config.macos_window_background_blur = 20
config.window_background_opacity = 0.6
config.window_decorations = "RESIZE"
config.default_cursor_style = "BlinkingBar"
-- config.window_background_image = "/Users/jonnycruz/Pictures/kanagawa.jpg"
-- config.window_background_image_hsb = {
--     -- Darken the background image by reducing it to 1/3rd
--     brightness = 0.09,
--
--     -- You can adjust the hue by scaling its value.
--     -- a multiplier of 1.0 leaves the value unchanged.
--     hue = 1.0,
--
--     -- You can adjust the saturation also.
--     saturation = 1.5,
-- }
config.keys = {
    {
        key = "f",
        mods = "CTRL",
        action = wezterm.action.ToggleFullScreen,
    },
}
config.mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

wezterm.on("user-var-changed", function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "ZEN_MODE" then
        local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
            while number_value > 0 do
                window:perform_action(wezterm.action.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            overrides.enable_tab_bar = false
        elseif number_value < 0 then
            window:perform_action(wezterm.action.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
        else
            overrides.font_size = number_value
            overrides.enable_tab_bar = false
        end
    end
    window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config
