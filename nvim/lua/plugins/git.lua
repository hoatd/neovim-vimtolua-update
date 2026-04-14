-- lua/plugins/git.lua
-- Git integration: command wrapper, UI, hunk signs, diff viewer.

return {
  -- ============================================================
  -- vim-fugitive: Git command wrapper (:G, :Git, etc.)
  -- No Lua setup needed — VimScript plugin, auto-initialises.
  -- ============================================================
  {
    "tpope/vim-fugitive",
    enabled = true,
  },

  -- ============================================================
  -- Neogit: Magit-style Git UI
  -- ============================================================
  {
    "NeogitOrg/neogit",
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      -- default config
    },
  },

  -- ============================================================
  -- Gitsigns: hunk signs in the sign column + hunk actions
  -- ============================================================
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local map = vim.keymap.set
          local opts = { silent = true, buffer = bufnr }

          -- --------------------------------------------------------
          -- Hunk navigation
          -- --------------------------------------------------------
          map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]h", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, vim.tbl_extend("force", opts, { desc = "Jump to next hunk" }))

          map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[h", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, vim.tbl_extend("force", opts, { desc = "Jump to previous hunk" }))

          -- --------------------------------------------------------
          -- Hunk text object
          -- --------------------------------------------------------
          map(
            { "o", "x" },
            "ih",
            gs.select_hunk,
            vim.tbl_extend("force", opts, { desc = "Select current hunk" })
          )

          -- --------------------------------------------------------
          -- Hunk actions
          -- --------------------------------------------------------
          map(
            "n",
            "<leader>hs",
            gs.stage_hunk,
            vim.tbl_extend("force", opts, { desc = "Stage current hunk" })
          )
          -- gs.stage_hunk() auto-detects staged hunks and inverts (unstages).
          -- undo_stage_hunk is deprecated; this is the modern equivalent.
          map(
            "n",
            "<leader>hu",
            gs.stage_hunk,
            vim.tbl_extend("force", opts, { desc = "Unstage hunk (toggle stage)" })
          )
          map(
            "n",
            "<leader>hr",
            gs.reset_hunk,
            vim.tbl_extend("force", opts, { desc = "Reset current hunk" })
          )

          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, vim.tbl_extend("force", opts, { desc = "Stage selected hunk" }))
          map("v", "<leader>hu", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, vim.tbl_extend("force", opts, { desc = "Unstage selected hunk (toggle stage)" }))
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, vim.tbl_extend("force", opts, { desc = "Reset selected hunk" }))

          map(
            "n",
            "<leader>hp",
            gs.preview_hunk,
            vim.tbl_extend("force", opts, { desc = "Preview current hunk" })
          )
          map(
            "n",
            "<leader>hi",
            gs.preview_hunk_inline,
            vim.tbl_extend("force", opts, { desc = "Preview current hunk inline" })
          )

          map(
            "n",
            "<leader>hS",
            gs.stage_buffer,
            vim.tbl_extend("force", opts, { desc = "Stage all hunks in buffer" })
          )
          map(
            "n",
            "<leader>hR",
            gs.reset_buffer,
            vim.tbl_extend("force", opts, { desc = "Reset all hunks in buffer" })
          )

          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, vim.tbl_extend("force", opts, { desc = "Blame current line" }))

          map(
            "n",
            "<leader>hd",
            gs.diffthis,
            vim.tbl_extend("force", opts, { desc = "Git diffthis vs index" })
          )
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end, vim.tbl_extend("force", opts, { desc = "Git diffthis vs base" }))

          map("n", "<leader>hQ", function()
            gs.setqflist("all")
          end, vim.tbl_extend("force", opts, { desc = "List all hunks to quickfix" }))
          map(
            "n",
            "<leader>hq",
            gs.setqflist,
            vim.tbl_extend(
              "force",
              opts,
              { desc = "List buffer hunks to quickfix" }
            )
          )

          -- --------------------------------------------------------
          -- Toggles
          -- --------------------------------------------------------
          map(
            "n",
            "<leader>tb",
            gs.toggle_current_line_blame,
            vim.tbl_extend("force", opts, { desc = "Toggle current line blame" })
          )
          map(
            "n",
            "<leader>tw",
            gs.toggle_word_diff,
            vim.tbl_extend("force", opts, { desc = "Toggle word diff" })
          )
        end,
      })
    end,
  },

  -- ============================================================
  -- Diffview: side-by-side diff and merge tool
  -- ============================================================
  {
    "sindrets/diffview.nvim",
    enabled = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- default config
    },
  },
}
