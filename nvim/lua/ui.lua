-- lua/ui.lua

-- Dracula colorscheme
require("dracula").setup({
  show_end_of_buffer = true,
  transparent_bg     = true,
  italic_comment     = true,
})
vim.cmd.colorscheme("dracula")

-- Devicons
require("nvim-web-devicons").setup({
  default = true,
})

-- Lualine
require("lualine").setup({})

-- Tabby
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
