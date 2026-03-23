-- lua/treesitter.lua

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

