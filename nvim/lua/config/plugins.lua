-- lua/config/plugins.lua

local M = {}

function M.setup()
  -- Register plugins
  vim.pack.add({
    -- Common dependencies
    "https://github.com/nvim-lua/plenary.nvim", -- Helper lua functions

    "https://github.com/Mofiqul/dracula.nvim", -- Dracula theme
    "https://github.com/nvim-tree/nvim-web-devicons", -- Icons
    "https://github.com/nvim-lualine/lualine.nvim", -- Statusline
    "https://github.com/nanozuki/tabby.nvim", -- Tabline
    { -- nvim-treesitter
      src = "https://github.com/nvim-treesitter/nvim-treesitter",
      branch = "main",
      run = ":TSUpdate",
    },
    { -- nvim-treesitter-textobjects
      src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
    { -- nvim-treesitter-context
      src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
      branch = "main",
    },
    "https://github.com/folke/persistence.nvim", -- Session manager
    "https://github.com/tpope/vim-fugitive", -- Git command wrap
    "https://github.com/NeogitOrg/neogit", -- Git UI
    "https://github.com/lewis6991/gitsigns.nvim", -- Git signs + hunk actions
    "https://github.com/sindrets/diffview.nvim", -- Side-by-side diff viewer
    "https://github.com/neovim/nvim-lspconfig", -- Core LSP configurations
    "https://github.com/williamboman/mason.nvim", -- Optional LSP installer
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/folke/trouble.nvim", -- Optional diagnostics UI
    "https://github.com/nvim-tree/nvim-tree.lua", -- File explorer
    -- Snippet
    "https://github.com/L3MON4D3/LuaSnip",           -- Snippet engine
    "https://github.com/rafamadriz/friendly-snippets", -- Huge collection of snippets
  })

  -- Plugin setups
  --
  -- Dracula colorscheme
  local ok_dracula, dracula = pcall(require, "dracula")
  if ok_dracula then
    dracula.setup({
      show_end_of_buffer = true,
      transparent_bg = true,
      italic_comment = true,
    })
    vim.opt.termguicolors = true
    vim.cmd.colorscheme("dracula")
    require("config.ui").hl_dracula()
  else
    vim.notify(
      "Plugin: Dracula failed setting up: " .. (dracula or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Devicons
  local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
  if ok_devicons then
    devicons.setup({
      default = true,
    })
  else
    vim.notify(
      "Plugin: Devicons failed setting up: " .. (devicons or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Lualine
  local ok_lualine, lualine = pcall(require, "lualine")
  if ok_lualine then
    lualine.setup({
      options = {
        theme = "dracula-nvim",
      },
    })
  else
    vim.notify(
      "Plugin: Lualine failed setting up: " .. (lualine or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Tabby
  local ok_tabby, tabby = pcall(require, "tabby")
  if ok_tabby then
    tabby.setup({
      preset = "active_wins_at_tail",
      --  option = {
      --    theme = {
      --      fill = 'TabLineFill',       -- tabline background
      --      head = 'TabLine',           -- head element highlight
      --      current_tab = 'TabLineSel', -- current tab label highlight
      --      tab = 'TabLine',            -- other tab label highlight
      --      win = 'TabLineSel',            -- window highlight
      --      tail = 'TabLine',           -- tail element highlight
      --    },
      --    nerdfont      = true,
      --    lualine_theme = nil,
      --    tab_name = {
      --      name_fallback = function(tabid) return tabid end,
      --    },
      --    buf_name = {
      --      mode = 'unique', -- or 'relative', 'tail', 'shorten'
      --    },
      --  },
    })
  else
    vim.notify(
      "Plugin: Tabby tabline failed setting up: " .. (tabby or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Persistence
  local ok_persistence, persistence = pcall(require, "persistence")
  if ok_persistence then
    persistence.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: persistence.vim failed setting up: "
        .. (persistence or "unknown error"),
      vim.log.levels.WARN
    )
  end

  local ok_nvimtree, nvimtree = pcall(require, "nvim-tree")
  if ok_nvimtree then
    -- Disable netrw at the very beginning (recommended)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Nvimtree failed setting up: "
        .. (nvimtree or "unknown error"),
      vim.log.levels.WARN
    )
  end

end

return M
