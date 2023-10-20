-- I am module-common.lua and I should live in ~/.config/wezterm/module-common.lua

local wezterm = require 'wezterm'

-- This is the module table that we will export
local module = {}

-- define a function in the module table.
-- Only functions defined in `module` will be exported to
-- code that imports this module.
-- The suggested convention for making modules that update
-- the config is for them to export an `apply_to_config`
-- function that accepts the config object, like this:
function module.apply_to_config(config)
  config.color_scheme = 'Symfonic'
  config.font = wezterm.font 'Roboto Mono'
  config.font_size = 10.0
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.enable_scroll_bar = true
  config.detect_password_input = true
  config.animation_fps = 60
  config.cursor_thickness = 2
  config.show_tab_index_in_tab_bar = false
end

-- return our module table
return module
