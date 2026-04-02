-- lua/config/lsp.lua

local M = {}

local servers = {
  "lua_ls",
  "pyright",
  "ts_ls",
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
  pyright = {},
  ts_ls = {},
  clangd = {},
}

local function setup_keymaps(bufnr)
  bufnr = bufnr or 0
  local opts = { silent = true, buffer = bufnr }
  local map = vim.keymap.set

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
end

local function on_attach(client, bufnr)
  local diagnostics = require("config.diagnostics")
  diagnostics.setup_keymaps(bufnr)
  setup_keymaps(bufnr)

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  local utils = require("utils")
  vim.notify(
    "LSP started for "
      .. utils.get_buffer_names(bufnr, { name = "[No Name]" }).name
      .. " ("
      .. client.name
      .. ")",
    vim.log.levels.INFO
  )
end

function M.setup()
  local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
  if not ok_mason_lsp then
    vim.notify(
      "LSP: Failed loading plugin mason-lspconfig",
      vim.log.levels.ERROR
    )
    return
  end
  mason_lsp.setup({
    ensure_installed = servers,
    automatic_enable = true,
  })

  local completion = require("config.completion")
  local capabilities = completion.get_capabilities()
  for _, server_name in ipairs(servers) do
    local config = server_configs[server_name] or {}
    config.on_attach = on_attach
    config.capabilities = capabilities
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
  end
end

return M
