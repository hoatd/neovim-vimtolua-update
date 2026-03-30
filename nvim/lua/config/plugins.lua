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
    "https://github.com/lewis6991/gitsigns.nvim", -- Git signs + hunk actions
    "https://github.com/NeogitOrg/neogit", -- Git UI
    "https://github.com/sindrets/diffview.nvim", -- Side-by-side diff viewer
    "https://github.com/neovim/nvim-lspconfig", -- Core LSP configurations
    "https://github.com/williamboman/mason.nvim", -- Optional LSP installer
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/folke/trouble.nvim", -- Optional diagnostics UI
  })

  -- Plugin setups
  --
  -- Dracula colorscheme
  if pcall(require, "dracula") then
    require("dracula").setup({
      show_end_of_buffer = true,
      transparent_bg = true,
      italic_comment = true,
    })
    vim.opt.termguicolors = true
    vim.cmd.colorscheme("dracula")
    require("config.ui").hl_dracula()
  end

  -- Devicons
  if pcall(require, "nvim-web-devicons") then
    require("nvim-web-devicons").setup({
      default = true,
    })
  end

  -- Lualine
  if pcall(require, "lualine") then
    require("lualine").setup({
      options = {
        theme = "dracula-nvim",
      },
    })
  end

  -- Tabby
  if pcall(require, "tabby") then
    require("tabby").setup({
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
  end

  -- Gitsigns
  local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
  if ok_gitsigns then
    gitsigns.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Gitsigns failed setting up: " .. (gitsigns or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Neogit
  local ok_neogit, neogit = pcall(require, "neogit")
  if ok_neogit then
    neogit.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Neogit failed setting up: " .. (neogit or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

return M
