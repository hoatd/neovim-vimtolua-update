-- lua/plugins/ai/codecompanion.lua
-- CodeCompanion: AI chat and inline assistant.
--
-- Enable: set enabled = true below.
-- Adapter defaults to copilot — requires copilot.lua enabled and signed in.
-- To use a different adapter, change the adapter fields in opts.

return {
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot",
          },
          inline = {
            adapter = "copilot",
          },
        },
      })
    end,
  },
}
