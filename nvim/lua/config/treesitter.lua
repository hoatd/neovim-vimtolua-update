-- lua/config/treesitter.lua

local M = {}

local utils = require("utils")
local ts = require("nvim-treesitter")
local ts_textobjects = require("nvim-treesitter-textobjects")
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_swap = require("nvim-treesitter-textobjects.swap")
local ts_select = require("nvim-treesitter-textobjects.select")

local parsers = {
  "bash",
  "c",
  "cpp",
  "cmake",
  "csv",
  "diff",
  "dockerfile",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "git_rebase",
  "json",
  "json5",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "pascal",
  "python",
  "query",
  "ssh_config",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
  -- "cuda",
  -- "make",
  -- "regex",
  -- "sql",
}

local function setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }
  local map = vim.keymap.set

  -- ============================================================
  -- Treesitter-aware movements
  -- ============================================================

  -- ============================================================
  -- Treesitter textobjects movements
  -- ============================================================

  -- Function / Class / Parameter / Smart text objects navigation
  map("n", "]f", function()
    ts_move.goto_next_start("@function.outer", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Jump to next function start" }))

  map(
    "n",
    "[f",
    function()
      ts_move.goto_previous_start("@function.outer", "textobjects")
    end,
    vim.tbl_extend("force", opts, { desc = "Jump to previous function start" })
  )

  map("n", "]c", function()
    ts_move.goto_next_start("@class.outer", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Jump to next class start" }))

  map("n", "[c", function()
    ts_move.goto_previous_start("@class.outer", "textobjects")
  end, vim.tbl_extend(
    "force",
    opts,
    { desc = "Jump to previous class start" }
  ))

  map("n", "]a", function()
    ts_move.goto_next_start("@parameter.inner", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Jump to next parameter" }))

  map("n", "[a", function()
    ts_move.goto_previous_start("@parameter.inner", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Jump to previous parameter" }))

  map({ "x", "o" }, "af", function()
    ts_select.select_textobject("@function.outer", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select around function" }))

  map({ "x", "o" }, "if", function()
    ts_select.select_textobject("@function.inner", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select inside function" }))

  map({ "x", "o" }, "ac", function()
    ts_select.select_textobject("@class.outer", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select around class" }))

  map({ "x", "o" }, "ic", function()
    ts_select.select_textobject("@class.inner", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select inside class" }))

  map({ "x", "o" }, "aa", function()
    ts_select.select_textobject("@parameter.outer", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select around parameter" }))

  map({ "x", "o" }, "ia", function()
    ts_select.select_textobject("@parameter.inner", "textobjects")
  end, vim.tbl_extend("force", opts, { desc = "Select inside parameter" }))

  map("n", "<leader>a", function()
    ts_swap.swap_next("@parameter.inner")
  end, vim.tbl_extend("force", opts, { desc = "Swap next node" }))

  map("n", "<leader>A", function()
    ts_swap.swap_previous("@parameter.outer")
  end, vim.tbl_extend("force", opts, { desc = "Swap previous node" }))
end

function M.setup()
  -- Install parsers automatically
  ts.install(parsers):wait(30000)

  -- Dont need setup by default
  -- ts.setup({})

  -- ============================================================
  -- Folding & indentation per-buffer setup
  -- ============================================================
  vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
    group = utils.augroup("treesitter"),
    callback = function(args)
      local buf = args.buf
      local ft = vim.bo[buf].filetype
      local lang = vim.treesitter.language.get_lang(ft)

      -- Skip if no language mapping exists
      if not lang then
        return
      end

      -- Check if parser is available before starting
      local ok, parser = pcall(vim.treesitter.require_language, lang)
      if not ok or not parser then
        return
      end

      vim.treesitter.start(buf, lang)
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  -- ============================================================
  -- Large file optimizations (>10 MB)
  -- ============================================================
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = utils.augroup("large_file"),
    callback = function(args)
      local buf = args.buf
      if vim.fn.getfsize(vim.api.nvim_buf_get_name(buf)) > 10 * 1024 * 1024 then
        vim.opt_local.swapfile = false
        vim.opt_local.bufhidden = "unload"
        vim.opt_local.undolevels = -1
        vim.opt_local.foldmethod = "manual" -- disable folding
        vim.opt_local.foldenable = false
        vim.opt_local.spell = false
        vim.notify(
          "Large file detected (>10MB). Performance mode enabled.",
          vim.log.levels.WARN
        )
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = utils.augroup("large_file"),
    callback = function(args)
      local buf = args.buf
      if vim.fn.getfsize(vim.api.nvim_buf_get_name(buf)) > 10 * 1024 * 1024 then
        vim.treesitter.stop(buf)
        vim.bo[buf].syntax = "on"
        vim.wo[0][0].cursorline = false
        vim.wo[0][0].relativenumber = false
        vim.notify(
          "Large file detected (>10MB). Performance mode enabled.",
          vim.log.levels.WARN
        )
      end
    end,
  })

  -- ============================================================
  -- nvim-treesitter-textobjects setup
  -- ============================================================
  ts_textobjects.setup({
    select = {
      enable = true,
      lookahead = true,
    },

    move = {
      enable = true,
      set_jumps = true,
    },

    swap = {
      enable = true,
    },
  })

  setup_keymaps()
end

return M
