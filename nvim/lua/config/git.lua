-- lua/config/git.lua
-- Git and relates setup

local M = {}

function M.setup()
  -- vim-fugitive
  -- dont need to setup fugitive as it is a vimscript instead

  -- Neogit
  local ok_neogit, neogit = pcall(require, "neogit")
  if ok_neogit then
    neogit.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Neogit failed setting up: " .. (neogit or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Gitsigns
  local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
  if ok_gitsigns then
    gitsigns.setup({
      current_line_blame = true,
      on_attach = function(bufnr)
        local map = vim.keymap.set
        local opts = { silent = true, buffer = bufnr }

        -- Hunk navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]h", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Jump to next hunk" }
        ))
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[h", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Jump to previous hunk" }
        ))

        -- Hunk text object
        map(
          { "o", "x" },
          "ih",
          gitsigns.select_hunk,
          vim.tbl_extend("force", opts, { desc = "Select current hunk" })
        )

        -- Hunk actions
        map(
          "n",
          "<leader>hs",
          gitsigns.stage_hunk,
          vim.tbl_extend("force", opts, { desc = "Stage current hunk" })
        )
        map("n", "<leader>hu", function()
          gitsigns.reset_hunk({ staged = true })
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Undo staged hunk" }
        ))
        map(
          "n",
          "<leader>hr",
          gitsigns.reset_hunk,
          vim.tbl_extend("force", opts, { desc = "Reset current hunk" })
        )
        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Stage selected hunk" }
        ))
        map("v", "<leader>hu", function()
          gitsigns.reset_hunk({
            vim.fn.line("."),
            vim.fn.line("v"),
            staged = true,
          })
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Undo staged hunk" }
        ))
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Reset selected hunk" }
        ))
        map(
          "n",
          "<leader>hp",
          gitsigns.preview_hunk,
          vim.tbl_extend("force", opts, { desc = "Preview current hunk" })
        )
        map(
          "n",
          "<leader>hi",
          gitsigns.preview_hunk_inline,
          vim.tbl_extend(
            "force",
            opts,
            { desc = "Preview current hunk inline" }
          )
        )

        map(
          "n",
          "<leader>hS",
          gitsigns.stage_buffer,
          vim.tbl_extend("force", opts, { desc = "Stage all hunks" })
        )
        map(
          "n",
          "<leader>hR",
          gitsigns.reset_buffer,
          vim.tbl_extend("force", opts, { desc = "Reset all hunks" })
        )

        map("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, vim.tbl_extend("force", opts, { desc = "Blame line" }))

        map(
          "n",
          "<leader>hd",
          gitsigns.diffthis,
          vim.tbl_extend("force", opts, { desc = "Git diffthis vs index" })
        )

        map("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, vim.tbl_extend(
          "force",
          opts,
          { desc = "Git diffthis vs base" }
        ))

        map(
          "n",
          "<leader>hQ",
          function()
            gitsigns.setqflist("all")
          end,
          vim.tbl_extend("force", opts, { desc = "List all hunks to quickfix" })
        )
        map(
          "n",
          "<leader>hq",
          gitsigns.setqflist,
          vim.tbl_extend(
            "force",
            opts,
            { desc = "List all hunks current buffer to quickfix" }
          )
        )

        -- Toggles
        map(
          "n",
          "<leader>tb",
          gitsigns.toggle_current_line_blame,
          vim.tbl_extend("force", opts, { desc = "Togge current line blame" })
        )
        map(
          "n",
          "<leader>tw",
          gitsigns.toggle_word_diff,
          vim.tbl_extend("force", opts, { desc = "Togge word diff" })
        )
      end,
    })
  else
    vim.notify(
      "Plugin: Gitsigns failed setting up: " .. (gitsigns or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Diffview
  local ok_diffview, diffview = pcall(require, "diffview")
  if ok_diffview then
    diffview.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Diffview failed setting up: " .. (diffview or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

return M
