-- lua/keymaps.lua

-- ============================================================
-- Leader-based delete/paste (without polluting register)
-- ============================================================
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"_dP', { desc = "Paste over selection without yanking" })

-- ============================================================
-- Window navigation
-- ============================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows with Ctrl+Arrow
vim.keymap.set("n", "<C-Up>",    "<cmd>resize +2<CR>",             { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>",  "<cmd>resize -2<CR>",             { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>",  "<cmd>vertical resize -2<CR>",    { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>",    { desc = "Increase window width" })

-- ============================================================
-- Quickfix & Location list
-- ============================================================
vim.keymap.set("n", "]q", ":cnext<CR>",     { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", ":cprev<CR>",     { desc = "Previous quickfix item" })
vim.keymap.set("n", "]l", ":lnext<CR>",     { desc = "Next location list item" })
vim.keymap.set("n", "[l", ":lprev<CR>",     { desc = "Previous location list item" })

-- ============================================================
-- Yank / Search improvements
-- ============================================================
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Center screen when jumping with n/N
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- ============================================================
-- Clipboard
-- ============================================================
vim.keymap.set("i", "<S-Insert>", "<C-R>+", { silent = true, desc = "Paste from system clipboard" })

-- ============================================================
-- Terminal keymap to exit insert mode
-- ============================================================
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, desc = "Exit terminal insert mode" })

-- ============================================================
-- Treesitter-aware movements
-- ============================================================

-- ============================================================
-- Treesitter textobjects movements
-- ============================================================

-- Function / Class / Parameter / Smart text objects navigation
vim.keymap.set("n", "]f", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
end, { desc = "Jump to next function start" })

vim.keymap.set("n", "[f", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
end, { desc = "Jump to previous function start" })

vim.keymap.set("n", "]c", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
end, { desc = "Jump to next class start" })

vim.keymap.set("n", "[c", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
end, { desc = "Jump to previous class start" })

vim.keymap.set("n", "]a", function()
  require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
end, { desc = "Jump to next parameter" })

vim.keymap.set("n", "[a", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
end, { desc = "Jump to previous parameter" })

vim.keymap.set({ "x", "o" }, "af", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select around function" })

vim.keymap.set({ "x", "o" }, "if", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select inside function" })

vim.keymap.set({ "x", "o" }, "ac", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Select around class" })

vim.keymap.set({ "x", "o" }, "ic", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Select inside class" })

vim.keymap.set({ "x", "o" }, "aa", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
end, { desc = "Select around parameter" })

vim.keymap.set({ "x", "o" }, "ia", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
end, { desc = "Select inside parameter" })
