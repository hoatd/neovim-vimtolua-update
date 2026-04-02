-- lua/config/dap.lua

local M = {}

local servers = {
  "python",
  "codelldb",
  -- "cppdbg",
}

function M.setup()
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
  })

  local dap = require("dap")

  vim.keymap.set("n", "<F5>", dap.continue)
  vim.keymap.set("n", "<F10>", dap.step_over)
  vim.keymap.set("n", "<F11>", dap.step_into)
  vim.keymap.set("n", "<F12>", dap.step_out)
  vim.keymap.set("n", "<leader>dc", dap.continue)
  vim.keymap.set("n", "<leader>do", dap.step_over)
  vim.keymap.set("n", "<leader>di", dap.step_into)
  vim.keymap.set("n", "<leader>dO", dap.step_out)

  -- toggle breakpoint
  vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)

  -- next / prev breakpoint
  vim.keymap.set("n", "]b", function()
    dap.jump_to_breakpoint(1)
  end)
  vim.keymap.set("n", "[b", function()
    dap.jump_to_breakpoint(-1)
  end)

  -- stack frame navigation
  vim.keymap.set("n", "]s", dap.down)
  vim.keymap.set("n", "[s", dap.up)
end

return M
