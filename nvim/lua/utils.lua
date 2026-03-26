-- lua/utils.lua

local M = {}

M.augroup = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

return M

