-- lua/config/dap.lua

local M = {}

local servers = {
  "python",
  "codelldb",
  -- "cppdbg",
}

function M.setup()
  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then
    vim.notify(
      "DAP: Failed loading plugin nvim-dap",
      vim.log.levels.ERROR
    )
    return
  end

  local ok_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")
  if not ok_mason_dap then
    vim.notify(
      "DAP: Failed loading plugin mason-nvim-dap",
      vim.log.levels.ERROR
    )
    return
  end
  mason_dap.setup({
    ensure_installed = servers,
    automatic_installation = true,
  })


  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  map(
    "n",
    "<F5>",
    dap.continue,
    vim.tbl_extend("force", opts, { desc = "Debug start/continue" })
  )
  map(
    "n",
    "<F10>",
    dap.step_over,
    vim.tbl_extend("force", opts, { desc = "Debug step over" })
  )
  map(
    "n",
    "<F11>",
    dap.step_into,
    vim.tbl_extend("force", opts, { desc = "Debug step into" })
  )
  map(
    "n",
    "<F12>",
    dap.step_out,
    vim.tbl_extend("force", opts, { desc = "Debug step out" })
  )
  map(
    "n",
    "<leader>xc",
    dap.continue,
    vim.tbl_extend("force", opts, { desc = "Debug start/continue" })
  )
  map(
    "n",
    "<leader>xo",
    dap.step_over,
    vim.tbl_extend("force", opts, { desc = "Debug step over" })
  )
  map(
    "n",
    "<leader>xi",
    dap.step_into,
    vim.tbl_extend("force", opts, { desc = "Debug step into" })
  )
  map(
    "n",
    "<leader>xO",
    dap.step_out,
    vim.tbl_extend("force", opts, { desc = "Debug step out" })
  )

  -- Toggle/set breakpoint
  map(
    "n",
    "<leader>b",
    dap.toggle_breakpoint,
    vim.tbl_extend("force", opts, { desc = "Toggle debug breakpoint" })
  )
  map(
    "n",
    "<leader>B",
    dap.set_breakpoint,
    vim.tbl_extend("force", opts, { desc = "Set debug breakpoint" })
  )

  -- Breakpoint navigation
  map(
    "n",
    "]b",
    function()
      dap.jump_to_breakpoint(1)
    end,
    vim.tbl_extend("force", opts, { desc = "Jump to next debug breakpoint" })
  )
  map(
    "n",
    "[b",
    function()
      dap.jump_to_breakpoint(-1)
    end,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to previous debug breakpoint" }
    )
  )

  -- stack frame navigation
  map(
    "n",
    "]s",
    dap.down,
    vim.tbl_extend("force", opts, { desc = "Jump to next debug stack frame" })
  )
  map(
    "n",
    "[s",
    dap.up,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to previous debug stack frame" }
    )
  )
end

return M
