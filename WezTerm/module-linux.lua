-- I am module-linux.lua and I should live in ~/.config/wezterm/module-linux.lua

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
  config.initial_cols = 120
  config.initial_rows = 36
  config.window_background_opacity = 0.95

  config.window_frame = {
    inactive_titlebar_bg = '#2b2e37', -- Qogir inactive title bar
    active_titlebar_bg = '#282a33', -- Qogir active title bar
  }
end

-- return our module table
return module
