local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup( {
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    config = function()
      require("dracula").setup( {
        show_end_of_buffer = true,
        transparent_bg = true,
        italic_comment = true,
      } )
      vim.cmd("colorscheme dracula")
      -- Better contrast for Dracula + tabby
      vim.cmd([[
        highlight TabLineSel guibg=#44475a guifg=#f8f8f2
        highlight TabLine guibg=#282a36 guifg=#6272a4
        highlight TabLineFill guibg=#1e1f29
      ]])
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {},
    config = function()
      require('nvim-web-devicons').setup( {} )
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      require('lualine').setup( {} )
    end,
  },
  {
    'nanozuki/tabby.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      require('tabby').setup( {
        preset = 'active_wins_at_tail',
        option = {
          theme = {
            fill = 'TabLineFill',       -- tabline background
            head = 'TabLine',           -- head element highlight
            current_tab = 'TabLineSel', -- current tab label highlight
            tab = 'TabLine',            -- other tab label highlight
            win = 'TabLineSel',            -- window highlight
            tail = 'TabLine',           -- tail element highlight
          },
          nerdfont = true,              -- whether use nerdfont
          lualine_theme = nil,          -- lualine theme name
          tab_name = {
            name_fallback = function(tabid)
              return tabid
            end,
          },
          buf_name = {
            mode = 'unique', -- or 'relative', 'tail', 'shorten'
          },
        },
      } )
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
  },
} )
