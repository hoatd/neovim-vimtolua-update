-- lua/config/diagnostics.lua

local M = {}

local diag = vim.diagnostic

--- Setup default diagnostic highlights (virtual text, signs)
local function setup_highlights()
end

--- Setup buffer-local diagnostic keymaps
-- @param bufnr buffer number
function M.setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }
  local map = vim.keymap.set

  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Jump to next diagnostic" }))

  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Jump to previous diagnostic" }))

  map("n", "]E", function()
    vim.diagnostic.jump({
      count = 1,
      float = true,
      severity = vim.diagnostic.severity.ERROR,
    })
  end, vim.tbl_extend("force", opts, { desc = "Jump to next error" }))

  map("n", "[E", function()
    vim.diagnostic.jump({
      count = -1,
      float = true,
      severity = vim.diagnostic.severity.ERROR,
    })
  end, vim.tbl_extend("force", opts, { desc = "Jump to previous error" }))

  map(
    "n",
    "<leader>e",
    vim.diagnostic.open_float,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Show diagnostics float under cursor" }
    )
  )

  map(
    "n",
    "<leader>q",
    vim.diagnostic.setloclist,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Populate location list with diagnostics" }
    )
  )
end

local diagnostic_map = {
  [vim.diagnostic.severity.ERROR] = { icon = "", hl = "DiagnosticError" },
  [vim.diagnostic.severity.WARN] = { icon = "", hl = "DiagnosticWarn" },
  [vim.diagnostic.severity.INFO] = { icon = "", hl = "DiagnosticInfo" },
  [vim.diagnostic.severity.HINT] = { icon = "", hl = "DiagnosticHint" },
}
local function build_diagnostic_sign_icons()
  local result = {}
  for severity, entry in pairs(diagnostic_map) do
    result[severity] = entry.icon or "●"
  end
  return result
end
local diagnostic_icons = build_diagnostic_sign_icons()

--- Main setup function
function M.setup()
  diag.config({
    underline = true, -- Underline problematic text
    virtual_text = {
      prefix = function(diagnostic)
        return diagnostic_map[diagnostic.severity].icon or "●"
      end,
      spacing = 1, -- Space between text and prefix
      severity = { min = vim.diagnostic.severity.HINT }, -- Show all levels
      virt_text_pos = "eol", -- End of line
      virt_text_win_col = 120, -- Should be the colorcolumn that greater than the length of current line
    },
    virtual_lines = false,
    signs = {
      text = diagnostic_icons,
      linehl = {
        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        [vim.diagnostic.severity.WARN] = "WarningMsg",
      },
    },
    float = {
      border = "rounded", -- Rounded border
      source = true, -- Show source in float
      prefix = function(diagnostic, i, total)
        local icon = diagnostic_map[diagnostic.severity].icon or "●"
        local hl = diagnostic_map[diagnostic.severity].hl or "DiagnosticInfo"
        return "(" .. i .. "/" .. total .. ") " .. icon .. " ", hl
      end,
      header = "", -- No header
      focusable = false, -- Non-focusable float
      style = "minimal", -- Minimal style to blend with UI
      winblend = 15, -- Match popup transparency
    },
    update_in_insert = false, -- Do not update diagnostics while typing
    severity_sort = true, -- Sort by severity: Error > Warn > Info > Hint
  })
  setup_highlights()
end

return M
