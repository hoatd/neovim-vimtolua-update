-- lua/plugins/ai/opencode.lua
-- Opencode: Neovim integration for a running opencode instance.
--
-- Enable: set enabled = true below.
-- Also uncomment the statusline line in plugins/ui.lua.
-- Start opencode with: opencode --port <any port>
-- The plugin auto-discovers the instance via pgrep + lsof on the --port flag.

return {
  {
    "nickjvandyke/opencode.nvim",
    enabled = false,
    config = function()
      require("opencode")
    end,
  },
}
