-- lua/ui.lua
-- =============================
-- Statusline, numbers, folds, colors, popup menus
-- =============================

-- Statusline / command line
vim.o.laststatus = 3
vim.o.showmode = true
vim.o.showcmd = true
vim.o.ruler = true
vim.wo.signcolumn = "yes"
vim.wo.cursorline = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 3
vim.o.title = true
vim.o.titlestring = "%t - neovim"

-- Session / splits / tabs
vim.opt.sessionoptions = "buffers,curdir,folds,help,localoptions,options,resize,tabpages,terminal,winpos,winsize"
vim.o.tabpagemax = 50
vim.o.showtabline = 2
vim.o.splitbelow = true
vim.o.splitright = true

-- Colors
vim.o.termguicolors = true
vim.cmd([[highlight PmenuSel guibg=#44475a]])

-- Listchars / Fillchars (tweak later with tabby/lualine)
vim.o.list = true
vim.o.listchars = "eol:↲,trail:¤,tab:→\\ ,space:˰,nbsp:␣,precedes:«,extends:»"
vim.o.fillchars = "eob:~,horiz:━,vert:┃,fold: ,foldopen:◣,foldclose:◥,diff:-"
