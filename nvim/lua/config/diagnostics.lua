-- lua/config/diagnostics.lua

local M = {}

local map = vim.keymap.set
local diag = vim.diagnostic

--- Setup default diagnostic highlights (virtual text, signs)
local function setup_highlights()
  local hl = vim.api.nvim_set_hl

  hl(
    0,
    "DiagnosticVirtualTextError",
    { fg = "#ff5555", italic = true, nocombine = true }
  )
  hl(
    0,
    "DiagnosticVirtualTextWarn",
    { fg = "#f1fa8c", italic = true, nocombine = true }
  )
  hl(
    0,
    "DiagnosticVirtualTextInfo",
    { fg = "#8be9fd", italic = true, nocombine = true }
  )
  hl(
    0,
    "DiagnosticVirtualTextHint",
    { fg = "#bd93f9", italic = true, nocombine = true }
  )

  -- Define signs
  vim.tbl_map(function(e)
    vim.fn.sign_define(e.name, { text = e.text, texthl = e.name, numhl = "" })
  end, {
    { name = "DiagnosticSignError", text = "✖" },
    { name = "DiagnosticSignWarn", text = "⚠" },
    { name = "DiagnosticSignHint", text = "➤" },
    { name = "DiagnosticSignInfo", text = "ℹ" },
  })

  -- Global diagnostic config
  diag.config({
    -- virtual_text = false,  -- Disable virtual text entirely, <leader>e - Open float, ]d / [d - Next/previous diagnostic
    virtual_text = {
      prefix = "●", -- Dot prefix
      spacing = 2, -- Space between text and prefix
      severity = { min = vim.diagnostic.severity.HINT }, -- Show all levels
      virt_text_pos = "eol", -- End of line
    },
    signs = true, -- Show signs in signcolumn
    underline = true, -- Underline problematic text
    update_in_insert = false, -- Do not update diagnostics while typing
    severity_sort = true, -- Sort by severity: Error > Warn > Info > Hint
    float = {
      border = "rounded", -- Rounded border
      source = "always", -- Show source in float
      prefix = "", -- No extra prefix
      header = "", -- No header
      focusable = false, -- Non-focusable float
      style = "minimal", -- Minimal style to blend with UI
      winblend = 15, -- Match popup transparency
    },
  })
end

--- Setup buffer-local diagnostic keymaps
-- @param bufnr buffer number
function M.setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }

  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Jump to next diagnostic" }))

  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, vim.tbl_extend("force", opts, { desc = "Jump to previous diagnostic" }))

  map("n", "[E", function()
    vim.diagnostic.jump({
      count = 1,
      float = true,
      severity = vim.diagnostic.severity.ERROR,
    })
  end, vim.tbl_extend("force", opts, { desc = "Jump to previous error" }))

  map("n", "]E", function()
    vim.diagnostic.jump({
      count = -1,
      float = true,
      severity = vim.diagnostic.severity.ERROR,
    })
  end, vim.tbl_extend("force", opts, { desc = "Jump to next error" }))

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

--- Main setup function
-- @param bufnr optional, for buffer-local keymaps
function M.setup()
  setup_highlights()
end

return M
