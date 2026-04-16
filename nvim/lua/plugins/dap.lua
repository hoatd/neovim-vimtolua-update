-- lua/plugins/dap.lua
-- Debug Adapter Protocol stack: core DAP, mason bridge, UI panels.

-- ============================================================
-- Active C/C++/Rust debugger backend (switch between codelldb and cppdbg)
-- ============================================================
local cpp_backend = "codelldb"
-- local cpp_backend = "cppdbg"

-- ============================================================
-- Mason-managed DAP packages
-- ============================================================
local dap_packages = {
  "python",
  "codelldb",
  "cppdbg", -- listed as "cpptools" in Mason
}

-- ============================================================
-- Helpers
-- ============================================================

--- Resolve the install path for a mason-managed package.
--- Returns nil (with a warning) if the package is unknown or not installed.
---@param name string Mason package name (e.g. "codelldb", "cpptools")
---@return string|nil
local function resolve_dap_package_from_mason_path(name)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    vim.notify("Mason: mason-registry failed to load", vim.log.levels.WARN)
    return nil
  end

  if not registry.has_package(name) then
    vim.notify("Mason: unknown package '" .. name .. "'", vim.log.levels.WARN)
    return nil
  end

  if not registry.is_installed(name) then
    vim.notify(
      "Mason: package '" .. name .. "' not installed — run :MasonInstall " .. name,
      vim.log.levels.WARN
    )
    return nil
  end

  return vim.fn.expand("$MASON/packages/" .. name)
end

--- Resolve the platform-aware native debugger path and MI mode.
--- macOS: lldb is native; Linux/Windows: gdb.
---@return { path: string, mode: string }
local function resolve_platform_aware_debugger_mi_mode()
  if vim.fn.has("mac") == 1 then
    return { path = vim.fn.exepath("lldb"), mode = "lldb" }
  else
    return { path = vim.fn.exepath("gdb"), mode = "gdb" }
  end
end

--- Prompt the user for a launch executable path via a floating input.
--- Uses vim.ui.input (intercepted session-wide by snacks.nvim when
--- `input = {}` is set in its opts — configured in plugins/ai/opencode.lua).
--- Bridges the async callback to a synchronous return via coroutine
--- yield/resume, which DAP requires because `program` must return a value.
--- assert(coroutine.running()) guards against accidental calls outside a
--- coroutine context; nvim-dap always invokes program() inside one.
---@return string|nil # Absolute path entered by the user, or nil if cancelled.
local input_launch_program = function()
  local co = assert(coroutine.running())
  vim.ui.input({
    prompt = "Executable: ",
    default = vim.fs.joinpath(vim.fn.getcwd(), "build", "/"),
    completion = "file",
  }, function(value)
    coroutine.resume(co, value)
  end)
  return coroutine.yield()
end

-- ============================================================
-- Adapter factories (resolved at runtime after mason installs)
-- ============================================================
local adapters = {
  codelldb = function()
    local path = resolve_dap_package_from_mason_path("codelldb")
    if not path then
      return nil
    end
    local bin = vim.fn.has("win32") == 1 and "codelldb.exe" or "codelldb"
    return {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fs.joinpath(path, "extension", "adapter", bin),
        args = { "--port", "${port}" },
      },
    }
  end,

  -- cppdbg adapter (alternative to codelldb — requires cpptools)
  cppdbg = function()
    local path = resolve_dap_package_from_mason_path("cpptools")
    if not path then
      return nil
    end
    local bin = vim.fn.has("win32") == 1 and "OpenDebugAD7.exe" or "OpenDebugAD7"
    return {
      type = "executable",
      command = vim.fs.joinpath(path, "extension", "debugAdapters", "bin", bin),
      id = "cppdbg", -- tells OpenDebugAD7 to use cppdbg.ad7Engine.json
      options = { detached = false },
    }
  end,
}

-- ============================================================
-- Launch configuration factories
-- ============================================================
local configurations = {
  -- cppdbg launch configuration (used when cpp_backend = "codelldb")
  codelldb = function()
    return {
      name = "Launch (codelldb)",
      type = "codelldb",
      request = "launch",
      program = input_launch_program,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    }
  end,

  -- cppdbg launch configuration (used when cpp_backend = "cppdbg")
  cppdbg = function()
    local dbg = resolve_platform_aware_debugger_mi_mode()
    if dbg.path == "" then
      vim.notify("DAP: cppdbg (gdb/lldb) not found in PATH", vim.log.levels.WARN)
      return nil
    end
    return {
      name = "Launch (cppdbg)",
      type = "cppdbg",
      request = "launch",
      program = input_launch_program,
      cwd = "${workspaceFolder}",
      stopAtEntry = false,
      MIMode = dbg.mode, -- "gdb" or "lldb"
      miDebuggerPath = dbg.path,
      setupCommands = {
        {
          description = "Enable pretty-printing",
          text = "-enable-pretty-printing",
          ignoreFailures = true,
        },
      },
    }
  end,
}

return {
  -- ============================================================
  -- nvim-dap: core Debug Adapter Protocol client
  -- ============================================================
  {
    "mfussenegger/nvim-dap",
    enabled = true,
    dependencies = {
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")

      -- --------------------------------------------------------
      -- mason-nvim-dap: install and wire up DAP adapters
      -- --------------------------------------------------------
      require("mason-nvim-dap").setup({
        ensure_installed = dap_packages,
        automatic_installation = true,
        handlers = {},
      })

      -- --------------------------------------------------------
      -- Adapter and launch config for the active C/C++/Rust backend
      -- --------------------------------------------------------
      local adapter = adapters[cpp_backend]()
      if not adapter then
        vim.notify(
          "DAP: Failed to locate adapter for " .. cpp_backend,
          vim.log.levels.WARN
        )
        return
      end
      dap.adapters[cpp_backend] = adapter

      local config = configurations[cpp_backend]()
      if not config then
        vim.notify(
          "DAP: Failed to locate configuration for " .. cpp_backend,
          vim.log.levels.WARN
        )
        return
      end
      dap.configurations.cpp = { config }
      dap.configurations.c = { config }
      dap.configurations.rust = { config }

      -- --------------------------------------------------------
      -- Keymaps
      -- --------------------------------------------------------
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Function keys
      map("n", "<F5>", dap.continue, vim.tbl_extend("force", opts, { desc = "Debug: start / continue" }))
      map("n", "<F10>", dap.step_over, vim.tbl_extend("force", opts, { desc = "Debug: step over" }))
      map("n", "<F11>", dap.step_into, vim.tbl_extend("force", opts, { desc = "Debug: step into" }))
      map("n", "<F12>", dap.step_out, vim.tbl_extend("force", opts, { desc = "Debug: step out" }))

      -- Leader equivalents
      map("n", "<leader>xc", dap.continue, vim.tbl_extend("force", opts, { desc = "Debug: start / continue" }))
      map("n", "<leader>xo", dap.step_over, vim.tbl_extend("force", opts, { desc = "Debug: step over" }))
      map("n", "<leader>xi", dap.step_into, vim.tbl_extend("force", opts, { desc = "Debug: step into" }))
      map("n", "<leader>xO", dap.step_out, vim.tbl_extend("force", opts, { desc = "Debug: step out" }))

      -- Breakpoints
      map("n", "<leader>b", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Debug: toggle breakpoint" }))
      map("n", "<leader>B", dap.set_breakpoint, vim.tbl_extend("force", opts, { desc = "Debug: set breakpoint" }))
      map("n", "<leader>bl", function()
        dap.list_breakpoints()
        vim.cmd("copen")
      end, vim.tbl_extend("force", opts, { desc = "Debug: list breakpoints (quickfix)" }))

      -- Stack frame navigation
      map("n", "]s", dap.down, vim.tbl_extend("force", opts, { desc = "Debug: next stack frame" }))
      map("n", "[s", dap.up, vim.tbl_extend("force", opts, { desc = "Debug: previous stack frame" }))
    end,
  },

  -- ============================================================
  -- mason-nvim-dap: bridge between mason and nvim-dap
  -- ============================================================
  {
    "jay-babu/mason-nvim-dap.nvim",
    enabled = true,
    dependencies = { "mason-org/mason.nvim" },
    lazy = true, -- loaded by nvim-dap config above
  },

  -- ============================================================
  -- nvim-dap-virtual-text: inline variable values during debug
  -- ============================================================
  {
    "theHamsta/nvim-dap-virtual-text",
    enabled = true,
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },

  -- ============================================================
  -- nvim-dap-ui: full debug UI panels (legacy, kept alongside dap-view)
  -- ============================================================
  {
    "rcarriga/nvim-dap-ui",
    enabled = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {},
  },

  -- ============================================================
  -- nvim-dap-view: modern DAP UI with winbar sections
  -- ============================================================
  {
    "igorlfs/nvim-dap-view",
    enabled = true,
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      winbar = {
        sections = {
          "watches",
          "scopes",
          "exceptions",
          "breakpoints",
          "threads",
          "repl",
          "sessions",
          "console",
        },
        default_section = "scopes",
        controls = {
          enabled = true,
        },
      },
      auto_toggle = true,
      -- follow_tab = true,
    },
  },
}
