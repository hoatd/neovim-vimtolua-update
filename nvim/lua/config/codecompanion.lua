-- lua/config/codecompanion.lua

local M = {}

function M.setup()
  local ok_codecompanion, codecompanion = pcall(require, "codecompanion")
  if ok_codecompanion then
    codecompanion.setup()
  else
    vim.notify(
      "Plugin: CodeCompanion failed setting up: "
        .. (codecompanion or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

return M
