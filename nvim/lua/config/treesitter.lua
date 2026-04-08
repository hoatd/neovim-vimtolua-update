-- lua/config/treesitter.lua

local M = {}

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
  local ok_ts_textobjects, ts_textobjects =
    pcall(require, "nvim-treesitter-textobjects")
  if not ok_ts_textobjects then
    return
  end

  -- Function / Class / Parameter / Smart text objects navigation
  local ok_ts_move, ts_move = pcall(require, "nvim-treesitter-textobjects.move")
  if not ok_ts_move then
    vim.notify(
      "Treesitter: nvim-treesitter-textobjects.move not available"
        .. (ts_move or "unknown error"),
      vim.log.levels.WARN
    )
  else
    map(
      "n",
      "]f",
      function()
        ts_move.goto_next_start("@function.outer", "textobjects")
      end,
      vim.tbl_extend("force", opts, { desc = "Jump to next function" })
    )
    map(
      "n",
      "[f",
      function()
        ts_move.goto_previous_start("@function.outer", "textobjects")
      end,
      vim.tbl_extend(
        "force",
        opts,
        { desc = "Jump to previous function" }
      )
    )
    map("n", "]c", function()
      ts_move.goto_next_start("@class.outer", "textobjects")
    end, vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to next class" }
    ))
    map(
      "n",
      "[c",
      function()
        ts_move.goto_previous_start("@class.outer", "textobjects")
      end,
      vim.tbl_extend("force", opts, { desc = "Jump to previous class" })
    )
    map("n", "]a", function()
      ts_move.goto_next_start("@parameter.inner", "textobjects")
    end, vim.tbl_extend("force", opts, { desc = "Jump to next parameter" }))
    map("n", "[a", function()
      ts_move.goto_previous_start("@parameter.inner", "textobjects")
    end, vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to previous parameter" }
    ))
  end

  -- Function / Class / Parameter / Smart text objects selection
  local ok_ts_select, ts_select =
    pcall(require, "nvim-treesitter-textobjects.select")
  if not ok_ts_select then
    vim.notify(
      "Treesitter: nvim-treesitter-textobjects.select not available"
        .. (ts_select or "unknown error"),
      vim.log.levels.WARN
    )
  else
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
  end

  -- Function / Class / Parameter / Smart text objects swap
  local ok_ts_swap, ts_swap = pcall(require, "nvim-treesitter-textobjects.swap")
  if not ok_ts_swap then
    vim.notify(
      "Treesitter: nvim-treesitter-textobjects.swap not available"
        .. (ts_swap or "unknown error"),
      vim.log.levels.WARN
    )
  else
    map("n", "<leader>a", function()
      ts_swap.swap_next("@parameter.inner")
    end, vim.tbl_extend("force", opts, { desc = "Swap next node" }))

    map("n", "<leader>A", function()
      ts_swap.swap_previous("@parameter.outer")
    end, vim.tbl_extend("force", opts, { desc = "Swap previous node" }))
  end
end

function M.setup()
  -- ============================================================
  -- nvim-treesitter setup
  -- ============================================================
  local ok_treesitter, treesitter = pcall(require, "nvim-treesitter")
  if not ok_treesitter then
    vim.notify(
      "Plugin: nvim-treesitter failed setting up: "
        .. (treesitter or "unknown error"),
      vim.log.levels.ERROR
    )
    return
  end
  -- Install parsers automatically
  treesitter.install(parsers)
  -- treesitter.setup({}) -- Dont need setup by default

  -- ============================================================
  -- nvim-treesitter-textobjects setup
  -- ============================================================
  local ok_ts_textobjects, ts_textobjects =
    pcall(require, "nvim-treesitter-textobjects")
  if not ok_ts_textobjects then
    vim.notify(
      "Plugin: nvim-treesitter-textobjects failed setting up: "
        .. (ts_textobjects or "unknown error"),
      vim.log.levels.WARN
    )
  else
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
  end

  -- ============================================================
  -- nvim-treesitter-context setup
  -- ============================================================
  local ok_ts_context, ts_context = pcall(require, "treesitter-context")
  if not ok_ts_context then
    vim.notify(
      "Plugin: nvim-treesitter-context failed setting up: "
        .. (ts_context or "unknown error"),
      vim.log.levels.WARN
    )
  else
    ts_context.setup({})
  end

  local utils = require("utils")

  -- ============================================================
  -- Per-Filetype setup
  -- ============================================================
  local LARGE_FILE_SIZE_LIMIT = 5 * 1024 * 1024
  local LONG_FILE_LINES_LIMIT = 20000

  -- ============================================================
  -- Large (>5 MB) or Long (20k lines) file optimizations
  -- ============================================================
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
      if size <= LARGE_FILE_SIZE_LIMIT then
        return
      end

      -- Mark this buffer as large file
      vim.b[buf].large_file = true

      vim.bo[buf].swapfile = false
      vim.bo[buf].undolevels = -1

      -- Large file → Performance mode disable swap and undo
      vim.notify(
        string.format(
          "Large file (%.1f MB) detected: " .. "No swap, no undo support.",
          size / (1024 * 1024)
        ),
        vim.log.levels.WARN
      )
    end,
  })

  vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
    group = utils.augroup("treesitter"),
    callback = function(args)
      local buf = args.buf

      local ft = vim.bo[buf].filetype or ""
      -- Early exit for non filetype buffer
      if ft == "" then
        return
      end

      local name = vim.api.nvim_buf_get_name(buf)
      -- Early exit for empty / unnamed buffer
      if name == "" then
        return
      end

      -- Skip if this buffer is in performance mode
      -- as it has been check in BufReadPre autocmds
      if vim.b[buf].large_file then
        return
      end

      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > LONG_FILE_LINES_LIMIT then
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

        vim.notify(
          string.format(
            "Very long file (%dK lines) detected: "
              .. "Treesitter features are disable.",
            math.floor(line_count / 1000)
          ),
          vim.log.levels.WARN
        )
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
        vim.log.levels.INFO
      )
    end,
  })
end

return M
