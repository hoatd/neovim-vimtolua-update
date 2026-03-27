-- lua/config/plugins.lua

local M = {}

function M.setup()
  -- Register plugins
  vim.pack.add({
    "https://github.com/Mofiqul/dracula.nvim", -- Theme
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
      version = "main",
    },
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
    require("lualine").setup({})
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
end

return M
