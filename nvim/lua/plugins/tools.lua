-- lua/plugins/tools.lua
-- General-purpose utility plugins: keymap helper, file explorer, session management.

return {
  -- ============================================================
  -- Which-key: keymap popup / documentation
  -- ============================================================
  {
    "folke/which-key.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {},
  },

  -- ============================================================
  -- Nvim-tree: file explorer
  -- ============================================================
  {
    "nvim-tree/nvim-tree.lua",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- ============================================================
  -- Persistence: session management
  -- ============================================================
  {
    "folke/persistence.nvim",
    enabled = true,
    config = function()
      local persistence = require("persistence")
      persistence.setup({
        -- default config
      })

      local map = vim.keymap.set
      local opts = { silent = true }

      map(
        "n",
        "<leader>qs",
        function()
          persistence.load()
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Load the session for the current directory" }
        )
      )
      map(
        "n",
        "<leader>ql",
        function()
          persistence.load({ last = true })
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Load the session that was last used" }
        )
      )
      map(
        "n",
        "<leader>qL",
        function()
          persistence.select()
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Select a session to load from a UI" }
        )
      )
      map(
        "n",
        "<leader>qd",
        function()
          persistence.stop()
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Stop persisting the session" }
        )
      )
    end,
  },
}
