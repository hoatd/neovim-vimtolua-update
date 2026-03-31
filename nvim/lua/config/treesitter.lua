-- lua/config/treesitter.lua

local M = {}

local utils = require("utils")
local ts = require("nvim-treesitter")
local ts_textobjects = require("nvim-treesitter-textobjects")
local ts_move = require("nvim-treesitter-textobjects.move")
local ts_swap = require("nvim-treesitter-textobjects.swap")
local ts_select = require("nvim-treesitter-textobjects.select")
local ts_context = require("treesitter-context")

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
  ts.install(parsers)

  -- Dont need setup by default
  -- ts.setup({})

  -- ============================================================
  -- Per-Filetype setup
  -- ============================================================
  vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
    group = utils.augroup("treesitter"),
    callback = function(args)
      local buf = args.buf
      local ft = vim.bo[buf].filetype or ""

      if ft == "" then
        return
      end

      -- Check if language mapping exists
      local lang = vim.treesitter.language.get_lang(ft) or ""
      if lang == "" then
        vim.notify(
          'Treesitter: Unsupported filetype "' .. ft .. '"',
          vim.log.levels.WARN
        )
        return
      end

      -- Check if parser is available before starting
      local lang_add_ok, lang_add_err = pcall(vim.treesitter.language.add, lang)
      if not lang_add_ok then
        vim.notify(
          "Treesitter: Failed loading parser for "
            .. lang
            .. ": "
            .. (lang_add_err or "unknown error"),
          vim.log.levels.WARN
        )
        return
      end

      -- Skip if this buffer is in performance mode
      if vim.b[buf].large_file then
        return
      end

      -- Now start treesitter with highlighting enabled
      local start_ok, start_err = pcall(vim.treesitter.start, buf, lang)
      if not start_ok then
        vim.notify(
          "Treesitter: Failed to start for "
            .. lang
            .. ": "
            .. (start_err or "unknown error"),
          vim.log.levels.WARN
        )
        return
      end

      -- Enable folding
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

      -- Enable indentation
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

      setup_keymaps(buf)

      vim.notify(
        "Treesitter started for "
          .. utils.get_buffer_names(buf, { name = "[No Name]" }).name,
        vim.log.levels.INFO,
        { timeout = 2000, replace = true }
      )
    end,
  })

  -- ============================================================
  -- Large (>5 MB) or Long (20k lines) file optimizations
  -- ============================================================
  local LARGE_FILE_SIZE = 5 * 1024 * 1024
  local LONG_FILE_LINES = 20000
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = utils.augroup("large_file"),
    callback = function(args)
      local buf = args.buf
      local name = vim.api.nvim_buf_get_name(buf)

      -- Early exit for empty / unnamed buffer
      if name == "" then
        return
      end

      -- Early exit for non file buffer: terminal, help, ...
      local ok, stat = pcall(vim.uv.fs_stat, name)
      if not ok or not stat or stat.type ~= "file" then
        return
      end

      -- Early exit for small files
      local size = stat.size
      if size <= LARGE_FILE_SIZE then
        return
      end

      -- Mark this buffer as large file
      vim.b[buf].large_file = true

      vim.bo[buf].swapfile = false
      vim.bo[buf].undolevels = -1

      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > LONG_FILE_LINES then
        -- Very long file → Full performance mode
        vim.wo.foldmethod = "manual"
        vim.wo.foldenable = false
        vim.wo.spell = false
        vim.wo.wrap = false
        vim.wo.cursorline = false
        vim.wo.cursorcolumn = false
        vim.wo.signcolumn = "no"
        vim.wo.relativenumber = false
        vim.wo.number = false

        pcall(vim.treesitter.stop, buf)

        vim.notify(
          string.format(
            "Treesitter: Very long file (%dK lines, %.1f MB) detected "
              .. "→ Full performance mode enabled: "
              .. "No swap, no undo, no spell, no wrap, no line visualization. "
              .. "Treesitter features are disable as well.",
            math.floor(line_count / 1000),
            size / (1024 * 1024)
          ),
          vim.log.levels.WARN
        )
      else
        -- Medium-large file → Light performance mode only disable swap and undo (keep highlighting,
        -- indentation, folding, spell, wrap, and line visualization)
        vim.notify(
          string.format(
            "Treesitter: Large file (%.1f MB) detected "
              .. "→ Light performance mode enabled: "
              .. "No swap, no undo support.",
            size / (1024 * 1024)
          ),
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

  -- ============================================================
  -- nvim-treesitter-context setup
  -- ============================================================
  ts_context.setup({})
end

return M
