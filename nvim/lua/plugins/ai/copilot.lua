-- lua/plugins/ai/copilot.lua
-- Copilot stack: copilot.lua with copilot-lsp as dependency (NES backend).
--
-- Enable NES workflow:
--   1. Set enabled = true below
--   2. Sign in: :LspCopilotSignIn

return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    event = "VimEnter",
    dependencies = {
      -- ============================================================
      -- copilot-lsp: NES language server backend
      -- ============================================================
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 100 -- Reduce NES request debounce (default: 500 ms)
        end,
        config = function()
          require("copilot-lsp").setup({
            nes = {
              move_count_threshold = 3, -- clear suggestion after 3 cursor moves
            },
          })

          local nes = require("copilot-lsp.nes")

          -- Jump to the start of the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-g>", function()
            nes.walk_cursor_start_edit()
          end, { desc = "NES: jump to edit location" })

          -- Accept / apply the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-a>", function()
            nes.apply_pending_nes()
          end, { desc = "NES: accept edit" })

          -- Dismiss the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-x>", function()
            nes.clear()
          end, { desc = "NES: dismiss edit" })
        end,
      },
    },
    config = function()
      require("copilot").setup({
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
          enabled = true,
          auto_trigger = true,
        },
        -- GHE authentication endpoint
        -- Using COPILOT_AUTH_PROVIDER_URL env variable (e.g. in .bashrc)
        -- Unset or empty falls back to github.com.
        auth_provider_url = vim.env.COPILOT_AUTH_PROVIDER_URL or nil,
      })
    end,
  },
}
