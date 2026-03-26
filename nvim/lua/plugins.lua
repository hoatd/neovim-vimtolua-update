vim.pack.add({
  "https://github.com/Mofiqul/dracula.nvim",       -- Theme
  "https://github.com/nvim-tree/nvim-web-devicons", -- Icons
  "https://github.com/nvim-lualine/lualine.nvim",   -- Statusline
  "https://github.com/nanozuki/tabby.nvim",        -- Tabline
  { -- nvim-treesitter
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    branch = "main",
    run = ":TSUpdate"
  },
  { -- nvim-treesitter-textobjects
    src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    version = "main",
  },
})
