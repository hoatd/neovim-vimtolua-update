-- lua/config/mason.lua

local M = {}

function M.get_package_path(name)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    vim.notify("Mason: mason-registry failed to load", vim.log.levels.WARN)
    return nil
  end

  if not registry.has_package(name) then
    vim.notify("Mason: unknown package '" .. name .. "'", vim.log.levels.WARN)
    return nil
  end

  if not registry.is_installed(name) then
    vim.notify(
      "Mason: package '" .. name .. "' not installed — run :MasonInstall " .. name,
      vim.log.levels.WARN
    )
    return nil
  end

  return vim.fn.expand("$MASON/packages/" .. name)
end

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
