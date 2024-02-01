-- I am module-pc.lua and I should live in ~/.config/wezterm/module-pc.lua

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
  config.default_domain = 'PC'
  config.ssh_domains = {
    {
      -- The name of this specific domain.  Must be unique amongst
      -- all types of domain in the configuration file.
      name = 'PC',
      -- identifies the host:port pair of the remote server
      -- Can be a DNS name or an IP address with an optional
      -- ":port" on the end.
      remote_address = '192.168.86.23',
      -- Whether agent auth should be disabled.
      -- Set to true to disable it.
      -- no_agent_auth = false,
      -- The username to use for authenticating with the remote host
      username = 'farmerbb',
      -- If true, connect to this domain automatically at startup
      -- connect_automatically = true,
      -- Specify an alternative read timeout
      -- timeout = 60,
      -- The path to the wezterm binary on the remote host.
      -- Primarily useful if it isn't installed in the $PATH
      -- that is configure for ssh.
      -- remote_wezterm_path = "/home/yourusername/bin/wezterm"
    },
  }
end

-- return our module table
return module
