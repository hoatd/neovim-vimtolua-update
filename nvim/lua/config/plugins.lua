-- lua/config/plugins.lua

local M = {}

-- Persistence
local setup_persistence = function()
  local ok_persistence, persistence = pcall(require, "persistence")
  if not ok_persistence then
    vim.notify(
      "Plugin: persistence.vim failed setting up: "
        .. (persistence or "unknown error"),
      vim.log.levels.WARN
    )
    return
  end
  persistence.setup({
    -- default config
  })

  local map = vim.keymap.set
  local opts = { silent = true }

  map(
    "n",
    "<leader>qs",
    function()
      persistence.load()
    end,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Load the session for the current directory" }
    )
  )
  map(
    "n",
    "<leader>ql",
    function()
      persistence.load({ last = true })
    end,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Load the session that was last used" }
    )
  )
  map(
    "n",
    "<leader>qL",
    function()
      persistence.select()
    end,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Select a session to load from an UI" }
    )
  )
  map("n", "<leader>qd", function()
    persistence.stop()
  end, vim.tbl_extend(
    "force",
    opts,
    { desc = "Stop persistence the session" }
  ))
end

function M.setup()
  -- Register plugins
  vim.pack.add({
    -- Common dependencies
    { src = "https://github.com/nvim-lua/plenary.nvim" }, -- Helper lua functions

    -- UI components
    { src = "https://github.com/Mofiqul/dracula.nvim" }, -- Dracula theme
    { src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- Icons
    { src = "https://github.com/nvim-lualine/lualine.nvim" }, -- Statusline
    { src = "https://github.com/nanozuki/tabby.nvim" }, -- Tabline

    -- treesitter
    {
      src = "https://github.com/nvim-treesitter/nvim-treesitter",
      branch = "main",
    }, -- nvim-treesitter
    {
      src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    }, -- nvim-treesitter-textobjects
    {
      src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
      branch = "main",
    }, -- nvim-treesitter-context

    -- Git relates
    { src = "https://github.com/tpope/vim-fugitive" }, -- Git command wrap
    { src = "https://github.com/NeogitOrg/neogit" }, -- Git UI
    { src = "https://github.com/lewis6991/gitsigns.nvim" }, -- Git signs + hunk actions
    { src = "https://github.com/sindrets/diffview.nvim" }, -- Side-by-side diff viewer
    { src = "https://github.com/folke/trouble.nvim" }, -- Optional diagnostics UI

    --
    { src = "https://github.com/folke/persistence.nvim" }, -- Session manager
    { src = "https://github.com/nvim-tree/nvim-tree.lua" }, -- File explorer

    -- Snippet
    { src = "https://github.com/L3MON4D3/LuaSnip" }, -- Snippet engine
    { src = "https://github.com/rafamadriz/friendly-snippets" }, -- Huge collection of snippets

    -- Completion
    { src = "https://github.com/hrsh7th/nvim-cmp" }, -- Core completion engine
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" }, -- LSP source
    { src = "https://github.com/hrsh7th/cmp-buffer" }, -- Buffer words
    { src = "https://github.com/hrsh7th/cmp-path" }, -- File paths
    { src = "https://github.com/hrsh7th/cmp-cmdline" }, -- : command line completion
    { src = "https://github.com/petertriho/cmp-git" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" }, -- Bridge between cmp and LuaSnip
    { src = "https://github.com/onsails/lspkind.nvim" }, -- Nice icons in completion menu

    -- Mason
    { src = "https://github.com/williamboman/mason.nvim" }, -- Optional LSP installer

    -- LSP
    { src = "https://github.com/neovim/nvim-lspconfig" }, -- Core LSP configurations
    { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
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
    })
  else
    vim.notify(
      "Plugin: Tabby tabline failed setting up: " .. (tabby or "unknown error"),
      vim.log.levels.WARN
    )
  end

  setup_persistence()

  local ok_nvimtree, nvimtree = pcall(require, "nvim-tree")
  if ok_nvimtree then
    nvimtree.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Nvimtree failed setting up: " .. (nvimtree or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

return M
