-- lua/ui.lua

-- Dracula colorscheme
require("dracula").setup({
  show_end_of_buffer = true,
  transparent_bg     = true,
  italic_comment     = true,
})
vim.cmd("colorscheme dracula")

-- Devicons
require("nvim-web-devicons").setup({
  default = true,
})

-- Lualine
require("lualine").setup({})

-- Tabby
-- Custom dracula-like highlights for better contrast with Tabby
vim.cmd([[
  highlight TabLineSel  guibg=#44475a guifg=#f8f8f2
  highlight TabLine     guibg=#282a36 guifg=#6272a4
  highlight TabLineFill guibg=#1e1f29
]])

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
