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
      "Mason: package '"
        .. name
        .. "' not installed — run :MasonInstall "
        .. name,
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

--- Scan build/ for the first executable file produced by CMake.
--- Fallback when the CMake File API reply is unavailable.
---@return string|nil # Absolute path to the first executable found, or nil.
local function resolve_cmake_build_program()
  local build = vim.fs.joinpath(vim.fn.getcwd(), "build")
  for name, type in vim.fs.dir(build) do
    if type == "file" then
      local path = vim.fs.joinpath(build, name)
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
  end
end

--- Resolve all EXECUTABLE targets via the CMake File API (cmake 3.14+).
--- Silently creates the codemodel-v2 query file if missing so the reply is
--- generated on the next cmake configure run (no reconfigure forced now).
--- Returns an empty table if the reply does not exist yet.
---@return string[] # Absolute paths to all EXECUTABLE targets in build/.
local function resolve_cmake_targets()
  local build = vim.fs.joinpath(vim.fn.getcwd(), "build")

  -- Ensure query file exists for the next cmake configure (idempotent).
  local query_dir = vim.fs.joinpath(build, ".cmake", "api", "v1", "query")
  vim.fn.mkdir(query_dir, "p")
  local qf = io.open(vim.fs.joinpath(query_dir, "codemodel-v2"), "a")
  if qf then
    qf:close()
  end

  -- Locate the reply index file.
  local reply_dir = vim.fs.joinpath(build, ".cmake", "api", "v1", "reply")
  local index_file
  for name, ftype in vim.fs.dir(reply_dir) do
    if ftype == "file" and name:match("^index%-.*%.json$") then
      index_file = vim.fs.joinpath(reply_dir, name)
      break
    end
  end
  if not index_file then
    return {}
  end

  -- Decode index → locate the codemodel reply file.
  local index = vim.fn.json_decode(vim.fn.readfile(index_file))
  local codemodel_file
  for _, reply in ipairs((index.reply or {})) do
    if reply.kind == "codemodel" then
      codemodel_file = vim.fs.joinpath(reply_dir, reply.jsonFile)
      break
    end
  end
  if not codemodel_file then
    return {}
  end

  -- Decode codemodel → collect EXECUTABLE targets.
  local codemodel = vim.fn.json_decode(vim.fn.readfile(codemodel_file))
  local config = (codemodel.configurations or {})[1] or {}
  local targets = {}
  for _, t in ipairs(config.targets or {}) do
    local tdata = vim.fn.json_decode(
      vim.fn.readfile(vim.fs.joinpath(reply_dir, t.jsonFile))
    )
    if tdata.type == "EXECUTABLE" then
      table.insert(targets, vim.fs.joinpath(build, tdata.name))
    end
  end
  return targets
end

--- Show a picker for multiple discovered CMake executable targets.
--- Uses vim.ui.select (intercepted by snacks.nvim picker when enabled).
--- Bridges the async callback to a synchronous return via coroutine
--- yield/resume, matching the same pattern as input_launch_program.
--- Pre-selects the first item via opts.snacks.on_show (snacks-specific;
--- ignored by the native vim.ui.select fallback).
---@param targets string[] List of absolute executable paths to choose from.
---@return string|nil # Chosen path, or nil if cancelled.
local function select_cmake_target(targets)
  local co = assert(coroutine.running())
  vim.ui.select(targets, {
    prompt = "DAP executable",
    format_item = function(path)
      return vim.fs.basename(path)
    end,
    snacks = {
      on_show = function(picker)
        picker.list:move(1)
      end,
    },
  }, function(choice)
    coroutine.resume(co, choice)
  end)
  return coroutine.yield()
end

--- Prompt the user for a launch executable path via a floating input.
--- Uses vim.ui.input (intercepted session-wide by snacks.nvim when
--- `input = {}` is set in its opts — configured in plugins/ai/opencode.lua).
--- Bridges the async callback to a synchronous return via coroutine
--- yield/resume, which DAP requires because `program` must return a value.
--- assert(coroutine.running()) guards against accidental calls outside a
--- coroutine context; nvim-dap always invokes program() inside one.
---@param default string Pre-filled path shown in the input.
---@return string|nil # Confirmed executable path, or nil if cancelled.
local function input_launch_program(default)
  local co = assert(coroutine.running())
  -- Position cursor at the start of the basename so the user can press <C-k>
  -- to delete just the filename and type a new one, keeping the directory.
  -- Columns are 0-indexed; dirname length + 1 skips the trailing slash.
  local basename_col = default and (#vim.fs.dirname(default) + 1) or 0
  vim.ui.input({
    prompt = "DAP executable: ",
    default = default,
    completion = "file",
    win = {
      footer = " <cr> launch   <esc> cancel ",
      footer_pos = "center",
      on_win = function(self)
        -- vim.schedule defers until after snacks has written the default text
        -- and issued startinsert!, both of which happen after Snacks.win().
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(self.win) then
            vim.api.nvim_win_set_cursor(self.win, { 1, basename_col })
          end
        end)
      end,
    },
  }, function(value)
    coroutine.resume(co, value)
  end)
  return coroutine.yield()
end

--- Read the cached launch program for the current project from vim.g.
--- vim.g.dap_launch_cache is a cwd-keyed table persisted across sessions
--- by folke/persistence.nvim via sessionoptions "globals".
---@return string|nil
local function get_cached_launch_program()
  local cache = vim.g.dap_launch_cache
  if type(cache) ~= "table" then
    return nil
  end
  return cache[vim.fn.getcwd()]
end

--- Persist the confirmed launch program for the current project into vim.g.
---@param path string
local function set_cached_launch_program(path)
  local cache = vim.g.dap_launch_cache
  if type(cache) ~= "table" then
    cache = {}
  end
  cache[vim.fn.getcwd()] = path
  vim.g.dap_launch_cache = cache
end

--- Resolve the launch executable via cache → CMake File API → build scan → user input.
--- Cache: last confirmed path, re-validated as executable each time.
--- File API: queries cmake targets (EXECUTABLE type); shows picker for multiple.
--- Build scan: fallback shallow scan of build/ for executable files.
--- Input: floating prompt pre-filled with the best candidate.
---@return string|nil # Confirmed executable path, or nil if cancelled.
local function select_launch_program()
  local cached = get_cached_launch_program()
  if cached and vim.fn.executable(cached) ~= 1 then
    cached = nil
  end

  local default = cached
  if not default then
    local targets = resolve_cmake_targets()
    if #targets == 1 then
      default = targets[1]
    elseif #targets > 1 then
      default = select_cmake_target(targets)
    end
  end

  default = default
    or resolve_cmake_build_program()
    or vim.fs.joinpath(vim.fn.getcwd(), "build", "/")

  local path = input_launch_program(default)
  if path and path ~= "" then
    set_cached_launch_program(path)
  end
  return path
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
    local bin = vim.fn.has("win32") == 1 and "OpenDebugAD7.exe"
      or "OpenDebugAD7"
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
      program = select_launch_program,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    }
  end,

  -- cppdbg launch configuration (used when cpp_backend = "cppdbg")
  cppdbg = function()
    local dbg = resolve_platform_aware_debugger_mi_mode()
    if dbg.path == "" then
      vim.notify(
        "DAP: cppdbg (gdb/lldb) not found in PATH",
        vim.log.levels.WARN
      )
      return nil
    end
    return {
      name = "Launch (cppdbg)",
      type = "cppdbg",
      request = "launch",
      program = select_launch_program,
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
      map(
        "n",
        "<F5>",
        dap.continue,
        vim.tbl_extend("force", opts, { desc = "Debug: start / continue" })
      )
      map(
        "n",
        "<F10>",
        dap.step_over,
        vim.tbl_extend("force", opts, { desc = "Debug: step over" })
      )
      map(
        "n",
        "<F11>",
        dap.step_into,
        vim.tbl_extend("force", opts, { desc = "Debug: step into" })
      )
      map(
        "n",
        "<F12>",
        dap.step_out,
        vim.tbl_extend("force", opts, { desc = "Debug: step out" })
      )

      -- Leader equivalents
      map(
        "n",
        "<leader>xc",
        dap.continue,
        vim.tbl_extend("force", opts, { desc = "Debug: start / continue" })
      )
      map(
        "n",
        "<leader>xo",
        dap.step_over,
        vim.tbl_extend("force", opts, { desc = "Debug: step over" })
      )
      map(
        "n",
        "<leader>xi",
        dap.step_into,
        vim.tbl_extend("force", opts, { desc = "Debug: step into" })
      )
      map(
        "n",
        "<leader>xO",
        dap.step_out,
        vim.tbl_extend("force", opts, { desc = "Debug: step out" })
      )

      -- Breakpoints
      map(
        "n",
        "<leader>b",
        dap.toggle_breakpoint,
        vim.tbl_extend("force", opts, { desc = "Debug: toggle breakpoint" })
      )
      map(
        "n",
        "<leader>B",
        dap.set_breakpoint,
        vim.tbl_extend("force", opts, { desc = "Debug: set breakpoint" })
      )
      map(
        "n",
        "<leader>bl",
        function()
          dap.list_breakpoints()
          vim.cmd("copen")
        end,
        vim.tbl_extend(
          "force",
          opts,
          { desc = "Debug: list breakpoints (quickfix)" }
        )
      )

      -- Stack frame navigation
      map(
        "n",
        "]s",
        dap.down,
        vim.tbl_extend("force", opts, { desc = "Debug: next stack frame" })
      )
      map(
        "n",
        "[s",
        dap.up,
        vim.tbl_extend("force", opts, { desc = "Debug: previous stack frame" })
      )
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
