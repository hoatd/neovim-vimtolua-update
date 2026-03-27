-- lua/config/treesitter.lua

local M = {}

local utils = require("utils")

M.parsers = {
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

function M.setup()
  -- Install parsers automatically
  require("nvim-treesitter").install(M.parsers)

  require("nvim-treesitter").setup {
    highlight = {
      enable = true,

      -- Disable on very large files
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,

      -- Keep vim regex highlighting for things Treesitter doesn't cover well
      additional_vim_regex_highlighting = { "markdown" },
    },

    indent = { enable = true, },

    textobjects = { enable = true,  },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection    = "<C-space>",
        node_incremental  = "<C-space>",
        node_decremental  = "<bs>",
      },
    },
  }

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
      vim.wo.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  -- ============================================================
  -- Large file optimizations (>10 MB)
  -- ============================================================
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = utils.augroup("large_file"),
    callback = function(args)
      if vim.fn.getfsize(vim.api.nvim_buf_get_name(args.buf)) > 10 * 1024 * 1024 then
        vim.opt_local.swapfile = false
        vim.opt_local.bufhidden = "unload"
        vim.opt_local.undolevels = -1
        vim.opt_local.foldmethod = "manual"   -- disable folding
        vim.opt_local.foldenable = false
        vim.opt_local.spell = false
        vim.notify("Large file detected (>10MB). Performance mode enabled.", vim.log.levels.WARN)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = utils.augroup("large_file"),
    callback = function(args)
      if vim.fn.getfsize(vim.api.nvim_buf_get_name(args.buf)) > 10 * 1024 * 1024 then
        vim.treesitter.stop(0, "highlight")
        vim.treesitter.stop(0, "indent")
        vim.bo[args.buf].syntax = "on"
        vim.wo[0][0].cursorline = false
        vim.wo[0][0].relativenumber = false
        vim.notify("Large file detected (>10MB). Performance mode enabled.", vim.log.levels.WARN)
      end
    end,
  })

  -- ============================================================
  -- nvim-treesitter-textobjects setup 
  -- ============================================================
  require("nvim-treesitter-textobjects").setup({
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        -- add more as you like: ["as"] = "@statement.outer", etc.
      },
    },

    move = {
      enable = true,
      set_jumps = true,
    },

    swap = {
      enable = true,
      swap_next = { ["<leader>a"] = "@parameter.inner" },
      swap_previous = { ["<leader>A"] = "@parameter.inner" },
    },
  })
end

return M
