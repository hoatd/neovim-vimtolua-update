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

