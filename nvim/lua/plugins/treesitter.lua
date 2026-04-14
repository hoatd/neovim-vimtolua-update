-- lua/plugins/treesitter.lua
-- Syntax tree, text objects, context breadcrumbs, and per-buffer TS activation.

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

local installed_langs = {}
for _, lang in ipairs(parsers) do
  installed_langs[lang] = true
end

--- Set up per-buffer treesitter-textobjects keymaps.
local function setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }
  local map = vim.keymap.set

  -- --------------------------------------------------------
  -- Movement: jump to next / previous node
  -- --------------------------------------------------------
  local ok_ts_move, ts_move = pcall(require, "nvim-treesitter-textobjects.move")
  if ok_ts_move then
    map("n", "]f", function()
      ts_move.goto_next_start("@function.outer", "textobjects")
    end, vim.tbl_extend("force", opts, { desc = "Jump to next function" }))
    map("n", "[f", function()
      ts_move.goto_previous_start("@function.outer", "textobjects")
    end, vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to previous function" }
    ))

    map("n", "]c", function()
      ts_move.goto_next_start("@class.outer", "textobjects")
    end, vim.tbl_extend("force", opts, { desc = "Jump to next class" }))
    map("n", "[c", function()
      ts_move.goto_previous_start("@class.outer", "textobjects")
    end, vim.tbl_extend("force", opts, { desc = "Jump to previous class" }))

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
  else
    vim.notify(
      "TS: nvim-treesitter-textobjects.move not available: "
        .. (ts_move or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- --------------------------------------------------------
  -- Selection: text objects
  -- --------------------------------------------------------
  local ok_ts_select, ts_select =
    pcall(require, "nvim-treesitter-textobjects.select")
  if ok_ts_select then
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
  else
    vim.notify(
      "TS: nvim-treesitter-textobjects.select not available: "
        .. (ts_select or "unknown error"),
      vim.log.levels.WARN
    )
  end

  -- --------------------------------------------------------
  -- Swap: swap adjacent nodes
  -- --------------------------------------------------------
  local ok_ts_swap, ts_swap = pcall(require, "nvim-treesitter-textobjects.swap")
  if ok_ts_swap then
    map("n", "<leader>a", function()
      ts_swap.swap_next("@parameter.inner")
    end, vim.tbl_extend(
      "force",
      opts,
      { desc = "Swap with next parameter" }
    ))
    map(
      "n",
      "<leader>A",
      function()
        ts_swap.swap_previous("@parameter.outer")
      end,
      vim.tbl_extend("force", opts, { desc = "Swap with previous parameter" })
    )
  else
    vim.notify(
      "TS: nvim-treesitter-textobjects.swap not available: "
        .. (ts_swap or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

--- Register per-buffer autocmds that start treesitter and set TS folding.
-- Large-file and long-file generic guards live in config/autocmds.lua and set
-- vim.b.large_file / vim.b.long_file; we only check those flags here.
local function register_buf_autocmd()
  local utils = require("utils")

  -- --------------------------------------------------------
  -- Per-buffer treesitter activation
  -- --------------------------------------------------------
  -- Sets vim.b[buf].ts_started on success so whichever of the two autocmds
  -- below fires second becomes a no-op (FileType fires before BufReadPost).
  local function activate_treesitter(args)
    local buf = args.buf
    if vim.b[buf].ts_started then
      return
    end

    local name = utils.get_buffer_names(buf, { name = "[No Name]" }).name

    -- Skip buffers flagged by the generic large-file / long-file guards
    if vim.b[buf].large_file then
      vim.notify("TS disabled: Very large file " .. name, vim.log.levels.WARN)
      return
    end
    if vim.b[buf].long_file then
      vim.notify("TS disabled: Very long file " .. name, vim.log.levels.WARN)
      return
    end

    -- Resolve language from filetype
    local ft = vim.bo[buf].filetype or ""
    if ft == "" then
      vim.notify(
        "TS disabled: Unknown filetype for " .. name,
        vim.log.levels.WARN
      )
      return
    end

    local lang = vim.treesitter.language.get_lang(ft) or ""
    if lang == "" then
      vim.notify(
        "TS: Unsupported filetype '" .. ft .. "' for " .. name,
        vim.log.levels.WARN
      )
      return
    end

    -- Load parser, bail out on failure
    local lang_ok, lang_add = pcall(vim.treesitter.language.add, lang)
    if not lang_ok or not lang_add then
      if installed_langs[lang] then
        vim.notify(
          "TS: Failed loading parser '"
            .. lang
            .. "' for "
            .. name
            .. " : "
            .. (lang_add or "unknown error"),
          vim.log.levels.WARN
        )
      end
      return
    end

    -- Start treesitter highlighting
    local start_ok, ts_start = pcall(vim.treesitter.start, buf, lang)
    if not start_ok then
      vim.notify(
        "TS: Failed to start '"
          .. lang
          .. "' for "
          .. name
          .. " : "
          .. (ts_start or "unknown error"),
        vim.log.levels.WARN
      )
      return
    end

    -- Enable TS-based folding
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.wo[win][0].foldmethod = "expr"
      vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end

    -- Note: indentexpr via nvim-treesitter is not available on the main branch.
    -- Indentation falls back to the filetype plugin (cindent, smartindent, etc.).

    setup_keymaps(buf)

    vim.b[buf].ts_started = true
    vim.schedule(function()
      vim.notify(
        "TS started for " .. name .. " (" .. lang .. ")",
        vim.log.levels.INFO
      )
    end)
  end

  -- FileType fires before BufReadPost for files opened from disk; the
  -- ts_started guard in activate_treesitter makes the second call a no-op.
  -- FileType also handles new/scratch buffers and :setfiletype.
  local ts_group = utils.augroup("treesitter")
  vim.api.nvim_create_autocmd("FileType", {
    group = ts_group,
    callback = activate_treesitter,
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = ts_group,
    callback = activate_treesitter,
  })
end

return {
  -- ============================================================
  -- nvim-treesitter: core parser and highlighting
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    branch = "main",
    build = ":TSUpdate",
    config = function()
      -- Install all listed parsers
      require("nvim-treesitter").install(parsers)
      -- Register per-buffer autocmds and keymaps
      register_buf_autocmd()
    end,
  },

  -- ============================================================
  -- nvim-treesitter-textobjects: select / move / swap by node
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    enabled = true,
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
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
    end,
  },

  -- ============================================================
  -- nvim-treesitter-context: sticky context breadcrumbs
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = true,
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
