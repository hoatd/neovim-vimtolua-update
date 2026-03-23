-- lua/autocmds.lua

-- =============================
-- Dynamic relative numbers
-- =============================
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.wo.relativenumber = false  -- hide relative numbers in insert mode
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    if vim.wo.diff then
      vim.wo.relativenumber = false
    else
      vim.wo.relativenumber = true   -- show relative numbers when leaving insert
    end
  end,
})

-- =============================
-- Dynamic cursorline
-- =============================
vim.o.cursorline = true

-- Focused window
vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
  pattern = "*",
  callback = function()
    if vim.wo.diff then
      vim.wo.cursorline = true
    else
      vim.wo.cursorline = true
    end
  end,
})

-- Unfocused window
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  callback = function()
    if vim.wo.diff then
      vim.wo.cursorline = true
    else
      vim.wo.cursorline = false
    end
  end,
})

-- Hide cursorline in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "bash",
    "lua",
    "vim",
    "c",
    "cpp",
    "diff",
    "cmake",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "ssh_config",
    "csv",
    "json",
    "python",
    "pascal",
    "comment",
    "markdown",
    -- "cuda",
    -- "dockerfile"
    -- "make",
    -- "regex",
    -- "sql",
  },
  callback = function(args)
    local ft = args.match
    local lang = vim.treesitter.language.get_lang(ft)
    if lang and vim.treesitter.language.add(lang) then
        vim.treesitter.start()
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
