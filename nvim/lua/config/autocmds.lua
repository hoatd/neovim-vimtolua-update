-- lua/config/autocmds.lua
-- Basic autocmds

local M = {}

local utils = require("utils")

function M.setup()
  -- ============================================================
  -- Relative number: only in normal mode (except diff mode)
  -- ============================================================
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = utils.augroup("number"),
    callback = function()
      vim.wo.relativenumber = false
    end,
  })

  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    group = utils.augroup("number"),
    callback = function()
      vim.wo.relativenumber = not vim.wo.diff
    end,
  })

  -- ============================================================
  -- Cursorline: only on focused window (respect diff mode)
  -- ============================================================
  vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
    group = utils.augroup("cursorline"),
    callback = function()
      vim.wo.cursorline = not vim.wo.diff
    end,
  })

  vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, {
    group = utils.augroup("cursorline"),
    callback = function()
      vim.wo.cursorline = false
    end,
  })

  -- ============================================================
  -- Highlight yanked text
  -- ============================================================
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = utils.augroup("yank"),
    callback = function()
      vim.highlight.on_yank({
        higroup = "IncSearch",
        timeout = 200,
        on_visual = true,
      })
    end,
  })

  -- ============================================================
  -- Quickfix: always open at bottom, full width
  -- ============================================================
  vim.api.nvim_create_autocmd("FileType", {
    group = utils.augroup("quickfix"),
    pattern = "qf",
    callback = function()
      local cmd = vim.api.nvim_parse_cmd('wincmd J', {})
      vim.api.nvim_cmd(cmd, {})   -- newer structured API
    end,
  })

  -- ============================================================
  -- Auto-reload files changed externally
  -- ============================================================
  vim.api.nvim_create_autocmd(
    { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
    {
      group = utils.augroup("checktime"),
      callback = function()
        if vim.fn.mode() ~= "c" and vim.bo.buftype ~= "nofile" then
          vim.api.nvim_command("checktime")
        end
      end,
    }
  )

  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = utils.augroup("checktime"),
    callback = function()
      vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
    end,
  })

  -- ============================================================
  -- Terminal behavior
  -- ============================================================
  vim.api.nvim_create_autocmd("TermOpen", {
    group = utils.augroup("terminal"),
    callback = function()
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
      vim.api.nvim_feedkeys("i", "n", false)
    end,
  })

  -- ============================================================
  -- Filetype-specific settings (Lua / Vim scripts)
  -- Better than old pattern-based autocmd
  -- ============================================================
  vim.api.nvim_create_autocmd("FileType", {
    group = utils.augroup("indent"),
    pattern = { "lua", "vim", "json", "html", "javascript" },
    callback = function()
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end,
  })
end

return M
