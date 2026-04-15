-- lua/plugins/lsp.lua
-- LSP stack: nvim-lspconfig + mason-lspconfig bridge.
-- Diagnostic keymaps are registered via LspAttach in config/diagnostics.lua.

-- ============================================================
-- Mason-managed LSP servers
-- ============================================================
local servers = {
  -- "bashls",
  -- "cmake",
  -- "gh_actions_ls",
  -- "html",
  -- "jsonls",
  "lua_ls",
  -- "marksman",
  -- "protols",
  -- "pyright",
  -- "ts_ls",
  "clangd",
  -- "vimls",
  -- "wasm_language_tools",
}

-- Extra servers not in mason-lspconfig's registry (installed manually).
-- Install: :MasonInstall copilot-language-server
--       or: npm install -g @github/copilot-language-server
-- Sign in: :LspCopilotSignIn
-- local extra_servers = {
--   "copilot",
-- }

-- ============================================================
-- Per-server configuration overrides
-- ============================================================
local server_configs = {
  -- clangd = {},
  -- copilot = {},
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
  -- ts_ls = {},
}

-- ============================================================
-- LSP keymaps (set per-buffer on attach)
-- ============================================================
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
    "gD",
    vim.lsp.buf.declaration,
    vim.tbl_extend("force", opts, { desc = "Go to declaration" })
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

-- ============================================================
-- on_attach: called when an LSP server attaches to a buffer
-- ============================================================
local function on_attach(client, bufnr)
  setup_keymaps(bufnr)

  -- Uncomment to enable inlay hints when the server supports them:
  -- if client.server_capabilities.inlayHintProvider then
  --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  -- end

  local utils = require("utils")
  vim.schedule(function()
    vim.notify(
      "LSP started for "
        .. utils.get_buffer_names(bufnr, { name = "[No Name]" }).name
        .. " ("
        .. client.name
        .. ")",
      vim.log.levels.INFO
    )
  end)
end

return {
  -- ============================================================
  -- nvim-lspconfig: LSP server configuration helpers
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    enabled = true,
    dependencies = {
      "mason-org/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Build capabilities; extend with whichever completion engine is active
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      else
        local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if ok_cmp_nvim_lsp then
          capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
        end
      end
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { "utf-16" }

      -- Configure and enable each managed server
      local function configure(server_name)
        local config = server_configs[server_name] or {}
        config.on_attach = on_attach
        config.capabilities = capabilities
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      for _, server_name in ipairs(servers) do
        configure(server_name)
      end

      -- Extra servers (not in mason-lspconfig registry)
      -- local def_caps = vim.lsp.protocol.make_client_capabilities()
      -- for _, server_name in ipairs(extra_servers) do
      --   local config = server_configs[server_name] or {}
      --   config.on_attach = on_attach
      --   config.capabilities = def_caps
      --   vim.lsp.config(server_name, config)
      --   vim.lsp.enable(server_name)
      -- end
    end,
  },

  -- ============================================================
  -- mason-lspconfig: bridge between mason and nvim-lspconfig
  -- ============================================================
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = true,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = servers,
      -- automatic_enable is off: we call vim.lsp.config() + vim.lsp.enable()
      -- explicitly in the nvim-lspconfig block above so that on_attach and
      -- capabilities are applied before the server starts.
      automatic_enable = false,
    },
  },
}
