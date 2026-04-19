-- lua/plugins/wezterm.lua
-- WezTerm <-> Neovim unified pane/split navigation via CTRL+hjkl
-- Gracefully inactive when not running inside WezTerm

return {
  {
    "willothy/wezterm.nvim",
    enabled = true,
    lazy = false,
    config = function()
      if vim.env.TERM_PROGRAM ~= "WezTerm" then
        vim.notify(
          "Wezterm: Neovim does not running inside WezTerm, WezTerm features unavailable",
          vim.log.levels.INFO
        )
        return
      end

      local ok_wezterm, wezterm = pcall(require, "wezterm")
      if not ok_wezterm then
        vim.notify(
          "Wezterm: Failed loaded wezterm.nvim: " .. wezterm,
          vim.log.levels.WARN
        )
        return
      end
      wezterm.setup({})

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map(
        "n",
        "<C-h>",
        function()
          wezterm.switch_pane.direction("Left")
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "WezTerm: move to Left pane/split" }
        )
      )
      map(
        "n",
        "<C-j>",
        function()
          wezterm.switch_pane.direction("Down")
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "WezTerm: move to Down pane/split" }
        )
      )
      map(
        "n",
        "<C-k>",
        function()
          wezterm.switch_pane.direction("Up")
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "WezTerm: move to Up pane/split" }
        )
      )
      map(
        "n",
        "<C-l>",
        function()
          wezterm.switch_pane.direction("Right")
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "WezTerm: move to Right pane/split" }
        )
      )
    end,
  },
}
