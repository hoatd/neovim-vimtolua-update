-- lua/config/mason.lua

local M = {}

function M.setup()
  local ok_mason, mason = pcall(require, "mason")
  if not ok_mason then
    vim.notify("Plugin: Failed loading plugin mason", vim.log.levels.ERROR)
    return
  end
  mason.setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })
end

return M
