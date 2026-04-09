-- lua/config/keymaps.lua
-- Basic keymaps

local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { silent = true }

  -- remap prefix keys
  if vim.g.keyboard_layout == "de" then
    map("n", "ü", "[", { remap = true })
    map("n", "+", "]", { remap = true })
  end

  -- ============================================================
  -- Yank / Search improvements
  -- ============================================================
  map(
    "n",
    "Y",
    "y$",
    vim.tbl_extend("force", opts, { desc = "Yank to end of line" })
  )

  map(
    { "n", "v" },
    "<leader>d",
    '"_d',
    vim.tbl_extend("force", opts, { desc = "Delete without yanking" })
  )

  map(
    { "n", "v" },
    "<leader>p",
    '"_dP',
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Paste over selection without yanking" }
    )
  )

  -- ============================================================
  -- Window navigation
  -- ============================================================
  map(
    "n",
    "<C-h>",
    "<C-w>h",
    vim.tbl_extend("force", opts, { desc = "Go to left window" })
  )
  map(
    "n",
    "<C-j>",
    "<C-w>j",
    vim.tbl_extend("force", opts, { desc = "Go to lower window" })
  )
  map(
    "n",
    "<C-k>",
    "<C-w>k",
    vim.tbl_extend("force", opts, { desc = "Go to upper window" })
  )
  map(
    "n",
    "<C-l>",
    "<C-w>l",
    vim.tbl_extend("force", opts, { desc = "Go to right window" })
  )

  -- Resize windows with Ctrl+Arrow
  map(
    "n",
    "<C-Up>",
    "<cmd>resize +2<CR>",
    vim.tbl_extend("force", opts, { desc = "Increase window height" })
  )
  map(
    "n",
    "<C-Down>",
    "<cmd>resize -2<CR>",
    vim.tbl_extend("force", opts, { desc = "Decrease window height" })
  )
  map(
    "n",
    "<C-Left>",
    "<cmd>vertical resize -2<CR>",
    vim.tbl_extend("force", opts, { desc = "Decrease window width" })
  )
  map(
    "n",
    "<C-Right>",
    "<cmd>vertical resize +2<CR>",
    vim.tbl_extend("force", opts, { desc = "Increase window width" })
  )

  -- ============================================================
  -- Quickfix & Location list
  -- ============================================================
  map(
    "n",
    "]q",
    ":cnext<CR>",
    vim.tbl_extend("force", opts, { desc = "Next quickfix item" })
  )
  map(
    "n",
    "[q",
    ":cprev<CR>",
    vim.tbl_extend("force", opts, { desc = "Previous quickfix item" })
  )
  map(
    "n",
    "]l",
    ":lnext<CR>",
    vim.tbl_extend("force", opts, { desc = "Next location list item" })
  )
  map(
    "n",
    "[l",
    ":lprev<CR>",
    vim.tbl_extend("force", opts, { desc = "Previous location list item" })
  )

  -- Center screen when jumping with n/N
  map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
  map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

  -- ============================================================
  -- Clipboard
  -- ============================================================
  map(
    "i",
    "<S-Insert>",
    "<C-R>+",
    vim.tbl_extend("force", opts, { desc = "Paste from system clipboard" })
  )

  -- ============================================================
  -- Terminal keymap to exit insert mode
  -- ============================================================
  map(
    "t",
    "<Esc>",
    "<C-\\><C-n>",
    vim.tbl_extend("force", opts, { desc = "Exit terminal insert mode" })
  )
end

return M
