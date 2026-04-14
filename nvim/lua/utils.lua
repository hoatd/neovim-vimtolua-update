-- lua/utils.lua
-- Utilize and helper functions

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
  local def_full = defaults.full or nil
  local def_relative = defaults.relative or nil
  local def_name = defaults.name or nil

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local full = vim.api.nvim_buf_get_name(bufnr)

  if full == "" then
    return {
      full = def_full,
      relative = def_relative,
      name = def_name,
    }
  end

  local relative = vim.fn.fnamemodify(full, ":.")
  local name = vim.fn.fnamemodify(full, ":t")

  return {
    full = full or def_full,
    relative = relative or def_relative,
    name = name or def_name,
  }
end

--- Apply a table of vim.opt options
-- @param tbl: key-value pairs table for options
--        If value is a single string/number, it will be applied directly
--        If value is a table, it will be joined with "," or "" for string flags
function M.apply_vim_options(tbl)
  local string_flags = {
    shortmess = true,
    formatoptions = true,
    cpoptions = true,
  }
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      if string_flags[k] then
        vim.opt[k] = table.concat(v, "")
      else
        vim.opt[k] = table.concat(v, ",")
      end
    else
      vim.opt[k] = v
    end
  end
end

--- Append a table of values to existing vim.opt options
-- @param tbl: table of key-value pairs
function M.append_vim_options(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      for _, val in ipairs(v) do
        vim.opt[k]:append(val)
      end
    else
      vim.opt[k]:append(v)
    end
  end
end

--- Ensure directories exist
-- @param base_path: root path
-- @param ...: list of directory names under base_path
function M.ensure_dirs_exist(base_path, ...)
  for _, name in ipairs({ ... }) do
    local path = base_path .. "/" .. name
    if vim.fn.isdirectory(path) == 0 then
      vim.fn.mkdir(path, "p")
    end
  end
end

return M
