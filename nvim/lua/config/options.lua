-- lua/config/options.lua

-- ============================================================================
-- Disable unneeded providers
-- ============================================================================
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0

-- ============================================================================
-- Helper functions
-- ============================================================================
-- Apply a table of options
-- @param tbl: key-value pairs table for options
--        If value is a single string/number, it will be applied directly
--        If value is a table, it will be joined with "," or "" for string flags
local function apply_options(tbl)
  local string_flags = {
    shortmess = true,
    formatoptions = true,
    cpoptions = true,
  }
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      if string_flags[k] then
        vim.opt[k] = table.concat(v, "")
      else
        vim.opt[k] = table.concat(v, ",")
      end
    else
      vim.opt[k] = v
    end
  end
end

-- Append a table of values to existing options
-- @param tbl: table of key-value pairs
local function append_options(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      for _, val in ipairs(v) do
        vim.opt[k]:append(val)
      end
    else
      vim.opt[k]:append(v)
    end
  end
end

-- Ensure directories exist
-- @param base_path: root path
-- @param ...: list of directory names under base_path
local function ensure_dirs(base_path, ...)
  for _, name in ipairs({ ... }) do
    local path = base_path .. "/" .. name
    if vim.fn.isdirectory(path) == 0 then
      vim.fn.mkdir(path, "p")
    end
  end
end

-- ============================================================================
-- Data directories for swap, undo, backup, tags
-- ============================================================================
local data_path = vim.fn.stdpath("data") -- ~/.local/share/nvim
ensure_dirs(data_path, "swap", "backup", "undo", "tags")

-- ============================================================================
-- Core / Global options
-- ============================================================================
local core_opts = {
  encoding = "utf-8", -- Internal character encoding
  fileencoding = "utf-8", -- Force file saving in utf-8 encoding
  fileformats = { -- File format detection order when reading files
    "unix", -- LF (\n) line endings (default Unix/Linux/macOS)
    "dos", -- CRLF (\r\n) line endings (Windows)
    "mac", -- CR (\r) line endings (old Mac OS)
  },
  mouse = "a", -- Enable mouse in all modes
  mousemodel = "popup_setpos", -- Right-click to open context menu
  clipboard = "unnamedplus", -- Use system clipboard
  belloff = "all", -- Disable all bells
  history = 10000, -- Remember commands and search history
  timeout = true, -- Enables key sequence timeout
  timeoutlen = 500, -- Key sequence timeout duration (ms)
  ttimeoutlen = 100, -- Terminal key code timeout (ms)
}
apply_options(core_opts)

-- ============================================================================
-- Editing behavior
-- ============================================================================
local editing_opts = {
  tabstop = 4, -- Number of spaces per tab
  softtabstop = 4, -- Multiple spaces as tabstop
  shiftwidth = 4, -- Indent size
  shiftround = true, -- Round indent to multiple of shiftwidth
  smarttab = true, -- Smart tab handling
  expandtab = true, -- Convert tabs to spaces
  copyindent = true, -- Preserve existing indentation
  autoindent = true, -- Indent new line same as previous
  smartindent = true, -- Smart C-style indentation
  foldmethod = "indent", -- Folding method (overridden by treesitter)
  foldexpr = "expr",
  foldlevel = 99, -- Max fold level
  foldlevelstart = 3, -- Initial fold level
  foldnestmax = 10, -- Max nested folds
  foldenable = false, -- Folds disabled by default
  backspace = { -- Insert mode backspace behavior
    "indent", -- Allow backspace over autoindent
    "eol", -- Allow backspace over line breaks
    "start", -- Allow backspace before insertion start
  },
  whichwrap = { -- Normal mode wrapping
    "b", -- Backspace moves to previous line
    "s", -- Space moves to next line
    "<", -- Left arrow
    ">", -- Right arrow
    "h", -- 'h' key
    "l", -- 'l' key
    "[", -- `[count` commands
    "]", -- `]count` commands
  },
}
local editing_opts_append = {
  nrformats = {
    "alpha", -- Increment/Decremental list by Ctrl+A/Ctrl+X
  },
}
apply_options(editing_opts)
append_options(editing_opts_append)

-- ============================================================================
-- Window / Display options
-- ============================================================================
local display_opts = {
  display = { -- How text is displayed in window
    "lastline", -- Show as much as possible of last line
    "uhex", -- Show unprintable characters in hex format (<xx>)
  },
  scrolloff = 8, -- Always show 3 lines above/below cursor
  sidescrolloff = 8, -- Show 5 chars left/right of cursor
  wrap = false, -- Do not wrap lines by default
  linebreak = true, -- Wrap at convenient points
  breakindent = true, -- Indent wrapped lines to match start of original
  showbreak = "↳ ", -- Symbol for wrap prefix
  colorcolumn = { -- Highlight column limits
    "80", -- Common limit for code style (PEP8, etc.)
    "120", -- Wider limit for modern displays / projects
  },
  shortmess = { -- Avoid annoying likes 'hit enter to continue' messages
    "a", -- All abbreviations (most common flags)
    "t", -- Truncate file messages at start
    "I", -- Disable the intro message (Neovim splash screen)
    "c",
    "C",
  },
  title = true, -- Show file in titlebar
  titlestring = "%t - neovim", -- Title using filename following by neovim
}
local display_opts_append = {
  cpoptions = "n", -- showbreak shown even in multi-byte character.
}
apply_options(display_opts)
append_options(display_opts_append)

-- ============================================================================
-- UI / Appearance
-- ============================================================================
local ui_opts = {
  number = true, -- Show line number of current line
  relativenumber = true, -- Show relative numbers for other lines
  cursorline = true, -- Highlight current line
  ruler = true, -- Show cursor position in statusline
  showmode = false, -- Don't show -- INSERT -- (statusline does it)
  showcmd = true, -- Show commandline in bottom bar
  cmdheight = 1, -- One line for :commands / messages
  laststatus = 3, -- Global statusline
  signcolumn = "yes:2", -- Always show sign columns (for git/lsp/diagnostics/...)
  numberwidth = 3,
  tabpagemax = 50, -- Max number of tab pages
  showtabline = 2, -- Always show tabline
  splitbelow = true, -- Horizontal split below
  splitright = true, -- Vertical split right
  list = true, -- Show invisible characters
  listchars = {
    eol = "↲", -- End-of-line
    trail = "¤", -- Trailing spaces
    tab = "→ ", -- Tab character
    space = "˰", -- Space
    nbsp = "␣", -- Non-breaking space
    precedes = "«", -- Text before window
    extends = "»", -- Text after window
  },
  fillchars = {
    eob = "~", -- End-of-buffer
    horiz = "━", -- Horizontal split line
    vert = "┃", -- Vertical split line
    fold = " ", -- Folded line filler
    foldopen = "◣", -- Open fold symbol
    foldclose = "◥", -- Closed fold symbol
    diff = "-", -- Diff filler line
  },
  guicursor = { -- Cursor shapes per mode
    "n-v-c:block", -- Normal, visual, command → block
    "i-ci-ve:ver25", -- Insert, cmd insert, visual insert → vertical bar
    "r-cr:hor20", -- Replace → horizontal bar
    "o:hor50", -- Operator-pending → horizontal bar
    "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- All modes blinking
    "sm:block-blinkwait175-blinkoff150-blinkon175", -- Showmatch blinking
  },
}
apply_options(ui_opts)

-- ============================================================================
-- File & Buffer Handling
-- ============================================================================
local buffers_opts = {
  hidden = true, -- Hide buffers with unsaved changes
  switchbuf = { -- Buffer switching behavior
    "useopen", -- Jump to already open buffer
    "uselast", -- Jump to last used buffer
    "usetab", -- Jump to buffer in tab
    "newtab", -- Open new tab if no match
  },
  lazyredraw = true, -- Speed up large file scrolling
  autoread = true, -- Auto read externally changed file
}
apply_options(buffers_opts)

local files_opts = {
  swapfile = true, -- Enable swap files
  directory = data_path .. "/swap//", -- Swap files dir
  backup = true, -- Enable backup files
  writebackup = true, -- Enable backup on write
  backupdir = data_path .. "/backup//", -- Backup dir
  undofile = true, -- Store undo history
  undodir = data_path .. "/undo//", -- Undo file dir
  undolevels = 1000, -- Many levels of undo
  undoreload = 1000,
  tags = data_path .. "/tags", -- Tag files directory
  tagstack = true,
}
apply_options(files_opts)

-- ============================================================================
-- Searching & Selection
-- ============================================================================
local searching_opts = {
  incsearch = true, -- Show matches while typing
  hlsearch = true, -- Highlight search matches
  ignorecase = true, -- Case-insensitive by default
  smartcase = true, -- Override ignorecase if uppercase used
  gdefault = true, -- :s replaces all matches by default
  magic = true, -- Regex patterns behave normally
  inccommand = "split", -- Live preview of substitutions
  showmatch = true, -- Jump to matching bracket briefly
  matchpairs = {
    "(:)", -- parentheses
    "[:]", -- square brackets
    "{:}", -- curly braces
    "<:>", -- angle brackets
  },
  selection = "inclusive",
  selectmode = {
    "mouse", -- Use Select mode with mouse
    "key", -- Use Select mode with Shift+movement
  },
}
apply_options(searching_opts)

local find_path_opts = {
  path = { -- Directories fpr finding files (used by commands like :find, gf, etc.)
    ".", -- Current directory
    "**", -- Recursively search subdirectories
  },
}
append_options(find_path_opts)

-- ============================================================================
-- Completion & Wildmenu
-- ============================================================================
local completion_opts = {
  wildmenu = true, -- tab completion with menu, bash-like
  wildmode = { -- get bash-like tab completions
    "longest", -- Complete up to the longest common string
    "list", -- Show all possible completions in a list
    "full", -- Complete the next match fully
  },
  wildignore = { -- File patterns to ignore during completion (wildmenu, :find, etc.)
    ".git", -- Git metadata directories
    "*.svn", -- Subversion metadata
    "*.hg", -- Mercurial metadata
    ".DS_Store", -- macOS system files
    ".DS_Store*", -- macOS system files with suffix
    "DS_Store*", -- macOS system files without dot
    "*.swp", -- Swap files
    "*.tmp", -- Temporary files
    "*.bak", -- Backup files
    "*.a", -- Static libraries
    "*.o", -- Object files
    "*.obj", -- Object files (Windows)
    "*.pyc*", -- Compiled Python files
    "*.pyx*", -- Cython compiled files
    "__pycache__", -- Python cache directories
    "*pycache__", -- Alternative Python cache pattern
  },
  completeopt = { -- Completion options for Insert mode
    "menu", -- Show a popup menu for completions
    "longest", -- Insert the longest common text of all matches
    "noselect", -- Do not select a match automatically
    "menuone", -- Show the menu even if there is only one match
    "preview", -- Show a preview window for the selected completion item
  },
  wildoptions = "pum",
  pumblend = 15,
  winblend = 15,
}
apply_options(completion_opts)

-- ============================================================================
-- Text Formatting & Diff
-- ============================================================================
local formatting_opts = {
  formatoptions = {
    "c", -- auto-wrap comments using textwidth
    "j", -- remove comment leader when joining lines
    "n", -- recognize numbered lists for auto-indenting
    "o", -- continue comments with 'o' or 'O'
    "r", -- continue comments when pressing Enter
    "q", -- allow formatting comments with gq
    "l", -- long lines not broken in insert mode
    "m", -- use 'matchpairs' for formatting
  },
  textwidth = 79,
}
apply_options(formatting_opts)

local diff_opts = {
  diffopt = {
    "vertical", -- Show diffs in vertical split instead of horizontal
    "filler", -- Display filler lines for unmodified lines to align diffs
    "iwhiteall", -- Ignore all whitespace differences
  },
}
append_options(diff_opts)

-- ============================================================================
-- Persistence (shada & session)
-- ============================================================================
local shada_opts = {
  shada = { -- persistent history
    "'100", -- max 100 lines of marks `'`
    ":100", -- max 100 command-line history entries
    "<100", -- max 100 search patterns
    "@100", -- max 100 input-line history (`@`)
    "/100", -- max 100 search history entries
    "%100", -- max 100 file marks
    "!", -- save/restore global variables
  },
}
apply_options(shada_opts)

local session_opts = {
  sessionoptions = { -- what to save in sessions
    "buffers", -- Save all open buffers
    "curdir", -- Restore the current working directory
    "folds", -- Save and restore folds
    "globals", -- Save global variables (g:) in the session
    "help", -- Include help windows in the session
    "localoptions", -- Save window-local options (like 'scrolloff', 'number')
    "options", -- Save global options (like 'shiftwidth', 'tabstop')
    "resize", -- Save window sizes
    "tabpages", -- Save tab pages layout
    "terminal", -- Save terminal buffers
    "winpos", -- Save the window position on the screen
    "winsize", -- Save window dimensions
  },
}
apply_options(session_opts)

-- ============================================================================
-- netrw
-- ============================================================================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- ============================================================================
-- Leader keys
-- ============================================================================
vim.g.mapleader = ","
vim.g.maplocalleader = ","
