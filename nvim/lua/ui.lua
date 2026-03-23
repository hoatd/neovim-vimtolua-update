-- lua/ui.lua

-- =============================
-- Statusline / Command Line / UI
-- =============================
vim.o.laststatus = 3              -- global statusline (Neovim 0.7+)
vim.o.showmode = true             -- show current mode (insert, replace, etc.)
vim.o.showcmd = true              -- show incomplete commands
vim.o.ruler = true                -- show cursor position
vim.o.cmdheight = 1               -- command-line height
vim.wo.signcolumn = "yes"         -- always show sign column
vim.wo.cursorline = true          -- highlight current line

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3

-- Title bar
vim.o.title = true
vim.o.titlestring = "%t - neovim"

-- Display options
vim.o.display = "lastline,uhex"   -- show last line and unprintable chars as hex

-- Session options
vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'

-- Folding
vim.o.foldenable = false           -- disable folding by default

-- Completion / pop-up menu
vim.o.completeopt = "menu,menuone,noselect"
vim.o.pumblend = 10

-- Colors
vim.o.termguicolors = true
vim.cmd([[highlight PmenuSel guibg=#44475a]])

-- Bell / visual feedback
vim.o.visualbell = true
vim.o.belloff = "all"
vim.o.errorbells = false

-- Cursor shapes (modern Lua way)
vim.opt.guicursor = table.concat({
  "n-v-c:block-Cursor/lCursor",
  "i-ci:ver25-CursorInsert",
  "r-cr:hor20-CursorReplace",
  "o:hor50",
}, ",")
