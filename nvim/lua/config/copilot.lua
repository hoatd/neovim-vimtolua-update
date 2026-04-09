local M = {}

function M.setup()
  vim.g.copilot_no_tab_map = true

  local map = vim.keymap.set
  local opts = { silent = true, noremap = true }

  map("i", "<M-l>", function()
    vim.fn.feedkeys(vim.fn["copilot#Accept"]("\r"), "n")
  end, vim.tbl_extend("force", opts, { desc = "Copilot accepts ghost" }))

  map(
    "i",
    "<M-ü>",
    "<Plug>(copilot-next)",
    vim.tbl_extend("force", opts, { desc = "Copilot next ghost" })
  )

  map(
    "i",
    "<M-+>",
    "<Plug>(copilot-previous)",
    vim.tbl_extend("force", opts, { desc = "Copilot previous ghost" })
  )

  -- Dismiss
  map(
    "i",
    "<C-]>",
    "<Plug>(copilot-dismiss)",
    vim.tbl_extend("force", opts, { desc = "Copilot dismiss ghost" })
  )

  map(
    "n",
    "<M-CR>",
    ":Copilot panel<CR>",
    vim.tbl_extend("force", opts, { desc = "Copilot opens panel" })
  )
end

return M
