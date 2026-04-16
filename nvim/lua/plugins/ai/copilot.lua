-- lua/plugins/ai/copilot.lua
-- Copilot stack: copilot.lua + copilot-lsp (NES backend).
--
-- Enable NES workflow:
--   1. Set enabled = true on both specs below
--   2. Set nes.enabled = true in copilot.lua opts
--   2. Sign in: :LspCopilotSignIn

return {
  -- ============================================================
  -- copilot.lua: Copilot suggestions + NES integration
  -- ============================================================
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    config = function()
      local opts = {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          -- hide_during_completion = true,
          -- debounce = 15,
          -- trigger_on_accept = true,
          keymap = {
            accept = "<M-l>",
            accept_word = "<M-Right>",
            accept_line = "<M-Down>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
            toggle_auto_trigger = false,
          },
        },
        nes = {
          -- Set enabled = true together with copilot-lsp below
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept_and_goto = "<M-g>",
            accept = "<M-a>",
            dismiss = "<Esc>",
          },
        },
        -- GHE authentication endpoint (set nil for github.com)
        -- auth_provider_url = nil,
        auth_provider_url = "https://straumann.ghe.com/",
      }
      require("copilot").setup(opts)
    end,
  },

  -- ============================================================
  -- copilot-lsp: NES language server backend
  -- Must be enabled together with nes.enabled = true above.
  -- ============================================================
  {
    "copilotlsp-nvim/copilot-lsp",
    enabled = true,
    config = function()
      require("copilot-lsp").setup({
        nes = {
          move_count_threshold = 3, -- clear suggestion after 3 cursor moves
        },
      })
    end,
  },
}
