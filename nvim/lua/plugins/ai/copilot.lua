-- lua/plugins/ai/copilot.lua
-- Copilot stack: copilot.lua with copilot-lsp as dependency for NES backend
-- and GHE authentication support (via OPILOT_AUTH_PROVIDER_URL env variable).
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
          vim.g.copilot_nes_debounce = 200 -- Reduced request debounce (default: 500 ms)

          -- Currently not used copilot_ls as copilot.lua directly integrates
          -- with copilot-lsp for NES, especially for the GHE authentication.
          -- If using copilot_ls with copilot-lsp, uncomment the line below and
          -- install a copilot-language-server (ex.: Mason install copilot-language-server).
          -- vim.lsp.enable("copilot_ls")
        end,

        config = function()
          local ok_copilot_lsp, copilot_lsp = pcall(require, "copilot-lsp")
          if not ok_copilot_lsp then
            vim.schedule(function()
              vim.notify(
                "Copilot/NES: copilot-lsp not found: " .. copilot_lsp,
                vim.log.levels.WARN
              )
            end)
            return
          end
          copilot_lsp.setup({
            nes = {
              move_count_threshold = 3, -- clear suggestion after 3 cursor moves
            },
          })

          local ok_copilot_lsp_nes, copilot_lsp_nes =
            pcall(require, "copilot-lsp.nes")
          if not ok_copilot_lsp_nes then
            vim.schedule(function()
              vim.notify(
                "Copilot/NES: copilot-lsp.nes not found: " .. copilot_lsp_nes,
                vim.log.levels.WARN
              )
            end)
            return
          end

          -- Try to jump to the start of the suggestion edit.
          -- If already at the start, then apply the pending suggestion
          -- and jump to the end of the edit.
          vim.keymap.set("n", "<Tab>", function()
            if vim.b[vim.api.nvim_get_current_buf()].nes_state then
              if not copilot_lsp_nes.walk_cursor_start_edit() then
                copilot_lsp_nes.apply_pending_nes()
                copilot_lsp_nes.walk_cursor_end_edit()
              end
              return nil
            end
            -- Fallback, resolving the terminal's inability to distinguish between
            -- `TAB` and `<C-i>` in normal mode
            return "<C-i>"
          end, { desc = "Accept Copilot NES suggestion", expr = true })

          -- Clear copilot suggestion with Esc if visible, otherwise preserve
          -- default Esc behavior
          vim.keymap.set("n", "<Esc>", function()
            if copilot_lsp_nes.clear() then
              return nil
            end
            -- Fallback to other functionality
            return "<Esc>"
          end, {
            desc = "Clear Copilot suggestion or fallback",
            expr = true,
          })

          -- Jump to the start of the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-g>", function()
            copilot_lsp_nes.walk_cursor_start_edit()
          end, { desc = "NES: jump to edit location" })

          -- Accept / apply the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-a>", function()
            copilot_lsp_nes.apply_pending_nes()
          end, { desc = "NES: accept edit" })

          -- Dismiss the pending NES edit
          vim.keymap.set({ "n", "i" }, "<M-x>", function()
            copilot_lsp_nes.clear()
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
          enabled = false, -- A better for blink-copilot
          auto_trigger = true,
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
        -- GHE authentication endpoint.
        -- Set COPILOT_AUTH_PROVIDER_URL in your shell profile for GHE,
        -- leave unset for github.com.
        auth_provider_url = vim.env.COPILOT_AUTH_PROVIDER_URL,
      })
    end,
  },
}
