-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.color_scheme = 'Symphonic (Gogh)'
config.font = wezterm.font 'Roboto Mono'
config.font_size = 10.0
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.enable_scroll_bar = true
config.initial_cols = 120
config.initial_rows = 36
config.detect_password_input = true
config.animation_fps = 60
config.window_background_opacity = 0.95
config.cursor_thickness = 2
config.show_tab_index_in_tab_bar = false

config.window_frame = {
  inactive_titlebar_bg = '#2b2e37', -- Qogir inactive title bar
  active_titlebar_bg = '#282a33', -- Qogir active title bar
}

-- and finally, return the configuration to wezterm
return config

