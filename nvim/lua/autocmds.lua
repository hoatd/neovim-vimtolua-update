-- lua/autocmds.lua
-- =============================
-- Autocommands
-- =============================

local api = vim.api

-- Toggle relative number in insert mode
api.nvim_create_autocmd({"InsertEnter"}, { command = "set norelativenumber" })
api.nvim_create_autocmd({"InsertLeave"}, { command = "set relativenumber" })

-- Toggle cursorline on focused window
api.nvim_create_autocmd({"WinEnter"}, { command = "set cursorline" })
api.nvim_create_autocmd({"WinLeave"}, { command = "set nocursorline" })

-- Highlight yanked text
api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { higroup='IncSearch', timeout=200 }
  end
})

-- Quickfix always at bottom
api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.cmd("wincmd J")
  end
})

-- Auto-read files changed externally
api.nvim_create_autocmd({"FocusGained","BufEnter","CursorHold","CursorHoldI"}, {
  command = "if mode() != 'c' | checktime | endif"
})

-- Notification on reload after external file changes
api.nvim_create_autocmd("FileChangedShellPost", {
  command = [[echohl WarningMsg | echo "File has changed on disk. Buffer reloaded." | echohl None]]
})

-- Terminal buffer settings
api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  command = "if &buftype == 'terminal' | startinsert | endif"
})

-- Terminal keymap to exit insert mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })
