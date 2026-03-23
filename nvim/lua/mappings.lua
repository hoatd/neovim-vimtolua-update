-- lua/keymaps.lua
-- =============================
-- Leader key mappings
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')
vim.keymap.set("n", "<leader>p", '"_dP')
vim.keymap.set("v", "<leader>p", '"_dP')

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Quickfix navigation
vim.keymap.set("n", "]q", ":cnext<CR>")
vim.keymap.set("n", "[q", ":cprev<CR>")

-- Yank / search improvements
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste from system clipboard
vim.keymap.set("i", "<S-Insert>", "<C-R>+")
