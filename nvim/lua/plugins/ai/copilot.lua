-- lua/plugins/ai/copilot.lua
-- Copilot stack: copilot.lua + copilot-lsp (NES backend) + sidekick (NES UI).
--
-- Enable all three together:
--   1. Set enabled = true on all three specs below
--   2. Set nes.enabled = true in copilot.lua opts
--   3. Install the LSP: :MasonInstall copilot-language-server
--      or: npm install -g @github/copilot-language-server
--   4. Sign in: :LspCopilotSignIn

return {
  -- ============================================================
  -- copilot.lua: Copilot suggestions + NES integration
  -- ============================================================
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    event = "InsertEnter",
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
          enabled = false,
          auto_trigger = true,
          keymap = {
            accept_and_goto = "<M-g>",
            accept = "<M-a>",
            dismiss = "<Esc>",
          },
        },
        -- GHE authentication endpoint (set nil for github.com)
        auth_provider_url = "https://straumann.ghe.com/",
        -- auth_provider_url = nil,

        -- Logging (uncomment to debug)
        -- logger = {
        --   file = vim.fn.stdpath("log") .. "/copilot-lua.log",
        --   file_log_level = vim.log.levels.OFF,
        --   print_log_level = vim.log.levels.WARN,
        --   trace_lsp = "off",        -- "off" | "debug" | "verbose"
        --   trace_lsp_progress = false,
        --   log_lsp_messages = false,
        -- },
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
    enabled = false,
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot-lsp").setup({
        nes = {
          move_count_threshold = 3, -- clear suggestion after 3 cursor moves
        },
      })
    end,
  },

  -- ============================================================
  -- sidekick.nvim: NES UI + CLI tools (Zellij mux backend)
  -- Must be enabled together with copilot.lua and copilot-lsp.
  -- ============================================================
  {
    "folke/sidekick.nvim",
    enabled = false,
    dependencies = {
      "zbirenbaum/copilot.lua",
      "copilotlsp-nvim/copilot-lsp",
    },
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
