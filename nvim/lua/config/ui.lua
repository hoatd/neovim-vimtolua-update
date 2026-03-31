--- lua/config/ui.lua
--- Basic UI

local utils = require("utils")

local M = {}

function M.hl_dracula()
  local hl = vim.api.nvim_set_hl

  hl(0, "PmenuSel", { bg = "#44475a", fg = "#ffffff" })

  hl(0, "TabLineSel", { bg = "#44475a", fg = "#f8f8f2" })
  hl(0, "TabLine", { bg = "#282a36", fg = "#6272a4" })
  hl(0, "TabLineFill", { bg = "#1e1f29" })

  hl(0, "GitSignsAdd", { fg = "#50fa7b" })
  hl(0, "GitSignsChange", { fg = "#f1fa8c" })
  hl(0, "GitSignsDelete", { fg = "#ff5555" })

  -- nvim-tree highlights for Dracula
  hl(0, "NvimTreeNormal", { bg = "#1e1f29" })
  hl(0, "NvimTreeFolderName", { fg = "#8be9fd" })
  hl(0, "NvimTreeOpenedFolderName", { fg = "#8be9fd", bold = true })
  hl(0, "NvimTreeGitDirty", { fg = "#f1fa8c" })
end

local function apply_ui_highlights()
  if vim.g.colors_name ~= "dracula" then
    return
  end

  M.hl_dracula()

  -- local hl = vim.api.nvim_set_hl

  --  -- Base diagnostic colors (these are the ones most colorschemes respect)
  --  hl(0, "DiagnosticError", { fg = "#ff5555", bold = true })
  --  hl(0, "DiagnosticWarn",  { fg = "#f1fa8c", bold = true })
  --  hl(0, "DiagnosticInfo",  { fg = "#8be9fd" })
  --  hl(0, "DiagnosticHint",  { fg = "#bd93f9" })
  --
  --  -- Virtual text specific (italic + slightly softer for inline text)
  --  hl(0, "DiagnosticVirtualTextError", { fg = "#ff5555", italic = true, nocombine = true })
  --  hl(0, "DiagnosticVirtualTextWarn",  { fg = "#f1fa8c", italic = true, nocombine = true })
  --  hl(0, "DiagnosticVirtualTextInfo",  { fg = "#8be9fd", italic = true, nocombine = true })
  --  hl(0, "DiagnosticVirtualTextHint",  { fg = "#bd93f9", italic = true, nocombine = true })
  --
  --  -- Optional: Also set the underline and floating window colors for consistency
  --  hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5555" })
  --  hl(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = "#f1fa8c" })
  --  hl(0, "DiagnosticUnderlineInfo",  { undercurl = true, sp = "#8be9fd" })
  --  hl(0, "DiagnosticUnderlineHint",  { undercurl = true, sp = "#bd93f9" })
end

function M.setup()
  local group = utils.augroup("colors")

  apply_ui_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    pattern = "*",
    callback = apply_ui_highlights,
    desc = "Dracula-style highlights for Tabby and PmenuSel",
  })
end

return M
