-- lua/settings.lua
-- =============================
-- Core editing / file handling / search
-- =============================

-- Leader
vim.g.mapleader = ","

-- Wildmenu & Command-line completion
vim.o.wildmenu = true
vim.o.wildmode = "longest,list,full"
vim.o.wildignore = ".git,*.svn,*.hg,.DS_Store,.DS_Store*,*.swp,*.tmp,*.bak,*.a,*.o,*.obj,*.pyc*,*.pyx*,*pycache,__pycache__"
vim.o.wildoptions = "pum"

-- Completion
vim.o.completeopt = "menu,menuone,longest,noselect,noinsert,preview"
vim.o.pumblend = 15
vim.o.winblend = 15

-- Undo / Swap / Backup (adjust later)
vim.o.swapfile = true
vim.o.undofile = true
vim.o.undodir = "~/.vim/undo"
vim.o.undolevels = 1000
vim.o.undoreload = 10000
vim.o.backup = false
vim.o.backupdir = "~/.vim/backup"

-- Search
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true
vim.o.inccommand = "split"

-- Formatting
vim.o.formatoptions = "cqjnoqr" -- disables 'a' and 't', enables comment formatting and numbered lists
vim.o.diffopt = "vertical,filler,iwhiteall"
vim.o.nrformats = vim.o.nrformats .. ",alpha" -- Ctrl+A/X can increment letters
vim.o.timeout = true
vim.o.timeoutlen = 500
vim.o.ttimeout = true
vim.o.ttimeoutlen = 100

-- Path for find commands
vim.o.path = vim.o.path .. ",.,**"

-- Filetype-based folding
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 3
vim.o.foldnestmax = 10
vim.o.foldenable = false

-- Display long lines / wrapping
vim.o.scrolloff = 3
vim.o.sidescrolloff = 5
vim.o.textwidth = 79
vim.o.colorcolumn = "80,120"
vim.o.wrap = false
vim.o.linebreak = true
vim.o.breakindent = true
vim.o.showbreak = "↳\\ "
vim.o.cpoptions = vim.o.cpoptions .. "n"
