-- lua/config/autocmds.lua
-- Basic autocmds

local M = {}

function M.setup()
  local utils = require("utils")

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
      local cmd = vim.api.nvim_parse_cmd("wincmd J", {})
      vim.api.nvim_cmd(cmd, {}) -- newer structured API
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

  -- ============================================================
  -- Large file guard (>5 MB): disable swap + undo
  -- Sets vim.b.large_file so plugins (e.g. treesitter) can check it.
  -- ============================================================
  local LARGE_FILE_SIZE_LIMIT = 5 * 1024 * 1024 -- 5 MB
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = utils.augroup("large_file"),
    callback = function(args)
      local buf = args.buf

      local ok, stat = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      if not ok or not stat or stat.type ~= "file" then
        return
      end

      if stat.size <= LARGE_FILE_SIZE_LIMIT then
        return
      end

      vim.b[buf].large_file = true

      vim.bo[buf].swapfile = false
      vim.bo[buf].undolevels = -1

      vim.notify(
        string.format(
          "Large file (%.1f MB) detected: No swap, no undo support.",
          stat.size / (1024 * 1024)
        ),
        vim.log.levels.WARN
      )
    end,
  })

  -- ============================================================
  -- Very long file (>20K lines): degrade display options
  -- Runs on BufReadPost so line count is available.
  -- Sets vim.b.long_file so plugins (e.g. treesitter) can check it.
  -- ============================================================
  local LONG_FILE_LINES_LIMIT = 20000
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = utils.augroup("long_file"),
    callback = function(args)
      local buf = args.buf
      local is_large = vim.b[buf].large_file -- set by BufReadPre above
      local is_long = vim.api.nvim_buf_line_count(buf) > LONG_FILE_LINES_LIMIT

      if not is_large and not is_long then
        return
      end

      vim.b[buf].long_file = true

      local win = vim.fn.bufwinid(buf)
      if win ~= -1 then
        vim.wo[win][0].foldmethod = "manual"
        vim.wo[win][0].foldenable = false
        vim.wo[win][0].spell = false
        vim.wo[win][0].wrap = false
        vim.wo[win][0].cursorline = false
        vim.wo[win][0].cursorcolumn = false
        vim.wo[win][0].signcolumn = "no"
        vim.wo[win][0].relativenumber = false
        vim.wo[win][0].number = false

        if is_long then
          vim.notify(
            string.format(
              "Very long file (%dK lines): Display features disabled.",
              math.floor(vim.api.nvim_buf_line_count(buf) / 1000)
            ),
            vim.log.levels.WARN
          )
        end
      end
    end,
  })
end

return M
