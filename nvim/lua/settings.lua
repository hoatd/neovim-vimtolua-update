-- lua/settings.lua

-- Encoding
vim.o.encoding = "utf-8"            -- internal character encoding
vim.o.fileencoding = "utf-8"        -- file saved in UTF-8
vim.o.fileformats = "unix,dos,mac"  -- support all newline formats

-- Clipboard
vim.o.clipboard = "unnamedplus"     -- use system clipboard

-- History
vim.o.history = 1000

-- Mouse
vim.o.mouse = "a"                   -- enable mouse in all modes
vim.o.mousemodel = "popup_setpos"   -- right-click opens context menu

-- Selection
vim.o.selection = "inclusive"
vim.o.selectmode = "mouse,key"

-- Compatibility
vim.cmd("set nocompatible")      -- disable vi compatibility
