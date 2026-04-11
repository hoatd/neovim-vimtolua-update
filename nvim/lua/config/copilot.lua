local M = {}

function M.setup()
  -- vim.g.copilot_enterprise_uri = "https://my-company.ghe.com"
  -- vim.g.copilot_workspace_folders = {
  --   vim.fn.expand("~/Projects/my-project"),
  --   vim.fn.expand("~/Projects/another-project"),
  -- }
  vim.g.copilot_no_tab_map = true

  local map = vim.keymap.set
  local opts = { silent = true, noremap = true }

  map("i", "<M-l>", function()
    local accept = vim.fn["copilot#Accept"]("")
    if accept ~= "" then
      vim.api.nvim_feedkeys(accept, "n", true)
    end
  end, vim.tbl_extend("force", opts, { desc = "Copilot accept suggestion" }))
  map(
    "i",
    "<M-ü>",
    "<Plug>(copilot-next)",
    vim.tbl_extend("force", opts, { desc = "Copilot next suggestion" })
  )
  map(
    "i",
    "<M-+>",
    "<Plug>(copilot-previous)",
    vim.tbl_extend("force", opts, { desc = "Copilot previous suggestion" })
  )
  map(
    "i",
    "<C-]>",
    "<Plug>(copilot-dismiss)",
    vim.tbl_extend("force", opts, { desc = "Copilot dismiss suggestion" })
  )
  map(
    "n",
    "<M-p>",
    ":Copilot panel<CR>",
    vim.tbl_extend("force", opts, { desc = "Copilot open panel" })
  )
end

return M
