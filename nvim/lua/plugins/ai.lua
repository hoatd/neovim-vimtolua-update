-- lua/plugins/ai.lua
-- AI coding assistants.

return {
  -- ============================================================
  -- GitHub Copilot (copilot.lua)
  -- Enable: set enabled = true
  -- ============================================================
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    event = "InsertEnter",
    config = function()
      local opts = {
        panel = {
          -- enabled = true,
          enabled = false,
          -- auto_refresh = false,
          -- keymap = {
          --   jump_prev = "[[",
          --   jump_next = "]]",
          --   accept = "<CR>",
          --   refresh = "gr",
          --   open = "<M-CR>",
          -- },
          -- layout = {
          --   position = "bottom", -- | top | left | right | bottom |
          --   ratio = 0.4,
          -- },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          -- auto_trigger = false,
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
          -- enabled = true,  -- enable together with copilot-lsp below
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
        --   trace_lsp = "off",           -- "off" | "debug" | "verbose"
        --   trace_lsp_progress = false,
        --   log_lsp_messages = false,
        -- },

        -- copilot_node_command = "node",  -- Node.js >= 22 required
        -- workspace_folders = {},
        -- copilot_model = "",
        -- disable_limit_reached_message = false,

        -- root_dir = function()
        --   return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
        -- end,

        -- should_attach = function(buf_id, _)
        --   if not vim.bo[buf_id].buflisted then return false end
        --   if vim.bo[buf_id].buftype ~= "" then return false end
        --   return true
        -- end,

        -- server = {
        --   type = "nodejs",  -- "nodejs" | "binary"
        --   custom_server_filepath = nil,
        -- },
        -- server_opts_overrides = {},
      }
      require("copilot").setup(opts)
    end,
  },

  -- ============================================================
  -- Copilot LSP — Next Edit Suggestions via language server
  -- Install: :MasonInstall copilot-language-server
  --       or: npm install -g @github/copilot-language-server
  -- Sign in: :LspCopilotSignIn
  -- Enable together with nes.enabled = true in copilot.lua above.
  -- ============================================================
  {
    "copilotlsp-nvim/copilot-lsp",
    enabled = false,
    config = function()
      local opts = {
        nes = {
          move_count_threshold = 3,  -- clear suggestion after 3 cursor moves
        },
      }
      require("copilot-lsp").setup(opts)
    end,
  },

  -- ============================================================
  -- Sidekick: NES + CLI tools integration (Zellij mux backend)
  -- Enable: set enabled = true
  -- ============================================================
  {
    "folke/sidekick.nvim",
    enabled = false,
    config = function()
      local opts = {
        nes = { enabled = true },
        cli = {
          mux = {
            backend = "zellij",
            enabled = true,
            create = "terminal",
          },
          tools = {
            -- claude = {},
          },
        },
        copilot = {
          status = { enabled = true },
        },
      }
      require("sidekick").setup(opts)

      -- Navigate to / apply the active Next Edit Suggestion.
      -- Falls back to a literal <M-p> if no suggestion is active.
      vim.keymap.set({ "n", "i" }, "<M-p>", function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<M-p>"
        end
      end, { expr = true, desc = "NES: goto / apply next edit suggestion" })
    end,
  },

  -- ============================================================
  -- CodeCompanion: AI chat and inline assistant
  -- Enable: set enabled = true
  -- ============================================================
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local opts = {
        -- interactions = {
        --   chat = {
        --     adapter = "copilot_acp",
        --   },
        --   inline = {
        --     adapter = "copilot",
        --   },
        -- },
      }
      require("codecompanion").setup(opts)
    end,
  },

  -- ============================================================
  -- Opencode: external opencode instance integration
  -- Start opencode with: opencode --port  (any port, plugin discovers it)
  -- Enable: set enabled = true; also uncomment statusline in plugins/ui.lua
  -- ============================================================
  {
    "nickjvandyke/opencode.nvim",
    enabled = false,
    config = function()
      -- Configure before the plugin loads.
      -- The plugin auto-discovers running opencode instances via pgrep + lsof,
      -- as long as they were started with --port (any port number).
      vim.g.opencode_opts = {
        -- server = {
        --   -- start = false,
        --   -- stop = false,
        --   -- toggle = false,
        -- },
      }
      require("opencode")
    end,
  },
}
