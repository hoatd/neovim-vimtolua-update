-- lua/utils.lua

local M = {}

function M.augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

--- Get buffer names with defaults
-- @param bufnr (number) buffer number
-- @param defaults (table) optional default values for fields { full = "", relative = "", name = "" }
-- @return table with fields: full, relative, name
function M.get_buffer_names(bufnr, defaults)
  defaults = defaults or {}
  local def_full     = defaults.full     or nil
  local def_relative = defaults.relative or nil
  local def_name     = defaults.name     or nil

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local full = vim.api.nvim_buf_get_name(bufnr)

  if full == "" then
    return {
      full     = def_full,
      relative = def_relative,
      name     = def_name,
    }
  end

  local relative = vim.fn.fnamemodify(full, ":.")
  local name     = vim.fn.fnamemodify(full, ":t")

  return {
    full     = full     or def_full,
    relative = relative or def_relative,
    name     = name     or def_name,
  }
end

return M

