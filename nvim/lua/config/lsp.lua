-- lua/config/lsp.lua

local M = {}

M.servers = {
  "lua_ls",
  -- "pyright",
  -- "ts_server",
  "clangd",
}

M.server_configs = {
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

function M.setup_mason()
  local ok, mason = pcall(require, "mason")
  if ok then mason.setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  }) end

  local ok2, mason_lsp = pcall(require, "mason-lspconfig")
  if ok2 then mason_lsp.setup({
    ensure_installed = M.servers,
    automatic_installation = true,
  }) end
end

local function on_attach(client, bufnr)
  vim.notify("LSP started: " .. client.name, vim.log.levels.INFO)
end

function M.setup_servers()
  for _, server_name in ipairs(M.servers) do
    local config = M.server_configs[server_name] or {}
    config.on_attach = on_attach
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
  end
end

function M.setup_keymaps()
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
end

function M.setup_trouble()
  local ok, trouble = pcall(require, "trouble")
  if ok then
    trouble.setup({
      auto_open = false,
      auto_close = true,
    })
  end
end

function M.setup()
  M.setup_mason()
  M.setup_servers()
  M.setup_keymaps()
  M.setup_trouble()
end

return M
