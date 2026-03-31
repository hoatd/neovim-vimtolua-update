-- lua/config/git.lua
-- Git and relates setup

local M = {}

function M.setup()
  -- vim-fugitive
  -- dont need to setup fugitive as it is a vimscript instead

  -- Neogit
  local ok_neogit, neogit = pcall(require, "neogit")
  if ok_neogit then
    neogit.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Neogit failed setting up: " .. (neogit or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Gitsigns
  local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
  if ok_gitsigns then
    gitsigns.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Gitsigns failed setting up: " .. (gitsigns or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- Diffview
  local ok_diffview, diffview = pcall(require, "diffview")
  if ok_diffview then
    diffview.setup({
      -- default config
    })
  else
    vim.notify(
      "Plugin: Diffview failed setting up: " .. (diffview or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

return M
