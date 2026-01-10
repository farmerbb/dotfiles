-- I am module-common.lua and I should live in ~/.config/wezterm/module-common.lua

local wezterm = require 'wezterm'

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on('update-status', function(window, pane)
  local info = pane:get_foreground_process_info()
  if info then
    window:set_right_status(
      wezterm.format {
        { Foreground = { Color = '#c0c0c0' } },
        { Background = { Color = '#282833' } },
        { Text = basename(info.executable) .. '   ' },
      }
    )
  else
    window:set_right_status ''
  end
end)

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
  config.audible_bell = "Disabled"
end

-- return our module table
return module
