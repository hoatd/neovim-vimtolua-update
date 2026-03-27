-- lua/config/lsp.lua

local M = {}

local utils = require("utils")
local diagnostics = require("config.diagnostics")

local map = vim.keymap.set

local servers = {
  "lua_ls",
  -- "pyright",
  -- "ts_ls",
  "clangd",
}

local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },
  },
  -- pyright = {},
  -- ts_server = {},
  clangd = {},
}

local function setup_mason()
  local ok, mason = pcall(require, "mason")
  if ok then
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
  end

  local ok2, mason_lsp = pcall(require, "mason-lspconfig")
  if ok2 then
    mason_lsp.setup({
      ensure_installed = servers,
      automatic_installation = true,
    })
  end
end

local function setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }

  map(
    "n",
    "gd",
    vim.lsp.buf.definition,
    vim.tbl_extend("force", opts, { desc = "Go to definition" })
  )

  map(
    "n",
    "K",
    vim.lsp.buf.hover,
    vim.tbl_extend("force", opts, { desc = "Hover documentation" })
  )

  map(
    "n",
    "gi",
    vim.lsp.buf.implementation,
    vim.tbl_extend("force", opts, { desc = "Go to implementation" })
  )

  map(
    "n",
    "gr",
    vim.lsp.buf.references,
    vim.tbl_extend("force", opts, { desc = "List references" })
  )

  map(
    "n",
    "<leader>rn",
    vim.lsp.buf.rename,
    vim.tbl_extend("force", opts, { desc = "Rename symbol" })
  )

  map(
    "n",
    "<leader>ca",
    vim.lsp.buf.code_action,
    vim.tbl_extend("force", opts, { desc = "Code action" })
  )

  map(
    "n",
    "<leader>e",
    vim.diagnostic.open_float,
    vim.tbl_extend("force", opts, { desc = "Show diagnostic float" })
  )
end

local function on_attach(client, bufnr)
  diagnostics.setup_keymaps(bufnr)
  setup_keymaps(bufnr)
  vim.notify(
    "LSP started for "
      .. utils.get_buffer_names(bufnr, { name = "[No Name]" }).name
      .. " ("
      .. client.name
      .. ")",
    vim.log.levels.INFO,
    { timeout = 2000, replace = true }
  )
end

local function setup_servers()
  for _, server_name in ipairs(servers) do
    local config = server_configs[server_name] or {}
    config.on_attach = on_attach
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
  end
end

local function setup_trouble()
  local ok, trouble = pcall(require, "trouble")
  if ok then
    trouble.setup({
      auto_open = false,
      auto_close = true,
    })
  end
end

function M.setup()
  setup_mason()
  setup_servers()
  setup_trouble()
end

return M
