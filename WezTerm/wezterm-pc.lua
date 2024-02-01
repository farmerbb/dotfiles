local common = require 'module-common'
local windows_common = require 'module-windows-common'
local pc = require 'module-pc'

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

common.apply_to_config(config)
windows_common.apply_to_config(config)
pc.apply_to_config(config)

-- and finally, return the configuration to wezterm
return config
