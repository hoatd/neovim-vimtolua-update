--- lua/config/ui.lua

local utils = require("utils")

local M = {}

local group = utils.augroup("colors")

function M.hl_dracula()
  vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#44475a", fg = "#f8f8f2" })
  vim.api.nvim_set_hl(0, "TabLine", { bg = "#282a36", fg = "#6272a4" })
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#1e1f29" })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#44475a", fg = "#ffffff" })
end

function M.setup()
  local function apply_ui_highlights()
    if vim.g.colors_name ~= "dracula" then
      return
    end

    M.hl_dracula()
  end

  vim.schedule(apply_ui_highlights)

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    pattern = "*",
    callback = apply_ui_highlights,
    desc = "Dracula-style highlights for Tabby and PmenuSel",
  })
end

return M
