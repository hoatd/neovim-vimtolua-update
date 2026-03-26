--- lua/config/ui.lua

local utils = require("utils")

-- Augroup for all UI highlights
local group = utils.augroup("colors")

local function apply_ui_highlights()
  -- Only apply if Dracula is active
  if vim.g.colors_name ~= "dracula" then
    return
  end

  vim.api.nvim_set_hl(0, "PmenuSel",    { bg = "#44475a", fg = "#ffffff" })

  -- Only apply if Tabby is loaded
  if not pcall(require, "tabby") then
    return
  end

  -- TabLine & PmenuSel highlights
  vim.api.nvim_set_hl(0, "TabLineSel",  { bg = "#44475a", fg = "#f8f8f2" })
  vim.api.nvim_set_hl(0, "TabLine",     { bg = "#282a36", fg = "#6272a4" })
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#1e1f29" })
end

-- Run once now
apply_ui_highlights()

-- Re-apply on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  pattern = "*",
  callback = apply_ui_highlights,
  desc = "Dracula-style highlights for Tabby and PmenuSel",
})
