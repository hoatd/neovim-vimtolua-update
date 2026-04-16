-- lua/plugins/ai/sidekick.lua
-- sidekick.nvim: NES UI + CLI tools (Zellij mux backend).
--
-- Enable independently of copilot.lua / copilot-lsp:
--   1. Set enabled = true below
--   2. Optionally enable nes.enabled = true if using NES workflow

return {
  {
    "folke/sidekick.nvim",
    enabled = true,
    config = function()
      require("sidekick").setup({
        nes = { enabled = true },
        cli = {
          mux = {
            backend = "zellij",
            enabled = true,
            create = "terminal",
          },
        },
        copilot = {
          status = { enabled = true },
        },
      })

      -- Apply / navigate the active Next Edit Suggestion.
      -- <M-p> is a no-op when no suggestion is active.
      vim.keymap.set({ "n", "i" }, "<M-p>", function()
        require("sidekick").nes_jump_or_apply()
      end, { desc = "NES: goto / apply next edit suggestion" })
    end,
  },
}
