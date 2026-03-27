-- lua/utils.lua

local M = {}

function M.augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

return M

