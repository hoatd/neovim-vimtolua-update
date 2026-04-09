-- lua/config/dap.lua

local M = {}

local using_cpp = "codelldb"
-- local using_cpp = "cppdbg"

local servers = {
  "python",
  "codelldb",
  "cppdbg", -- cpptools in the Mason
}

local function get_debugger()
  -- macOS: gdb is painful to codesign, lldb is native
  -- Linux: gdb is standard
  -- Windows: gdb from MinGW/MSYS2
  if vim.fn.has("mac") == 1 then
    return { path = vim.fn.exepath("lldb"), mode = "lldb" }
  else
    return { path = vim.fn.exepath("gdb"), mode = "gdb" }
  end
end

local adapters = {
  codelldb = function()
    local mason = require("config.mason")
    local path = mason.get_package_path("codelldb")
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

  cppdbg = function()
    local mason = require("config.mason")
    local path = mason.get_package_path("cpptools")
    if not path then
      return nil
    end
    local bin = vim.fn.has("win32") == 1 and "OpenDebugAD7.exe"
      or "OpenDebugAD7"
    return {
      type = "executable",
      command = vim.fs.joinpath(path, "extension", "debugAdapters", "bin", bin),
      id = "cppdbg", -- ← tells OpenDebugAD7 to use cppdbg.ad7Engine.json
      options = {
        detached = false,
      },
    }
  end,
}

local configurations = {
  codelldb = function()
    return {
      name = "Launch (codelldb)",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input(
          "Executable: ",
          vim.fs.joinpath(vim.fn.getcwd(), "build", ""),
          "file"
        )
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    }
  end,

  cppdbg = function()
    local dbg = get_debugger()
    if dbg.path == "" then
      vim.notify("DAP: cppdbg(gdb/lldb) not found in PATH", vim.log.levels.WARN)
      return nil
    end
    return {
      name = "Launch (cppdbg)",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input(
          "Executable: ",
          vim.fs.joinpath(vim.fn.getcwd(), "build", ""),
          "file"
        )
      end,
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

function M.setup()
  local ok_dap, dap = pcall(require, "dap")
  if not ok_dap then
    vim.notify("DAP: Failed loading plugin nvim-dap", vim.log.levels.ERROR)
    return
  end

  local ok_mason_dap, mason_dap = pcall(require, "mason-nvim-dap")
  if not ok_mason_dap then
    vim.notify(
      "DAP: Failed loading plugin mason-nvim-dap",
      vim.log.levels.ERROR
    )
    return
  end
  mason_dap.setup({
    ensure_installed = servers,
    automatic_installation = true,
    handlers = {},
  })

  local adapter_cpp = adapters[using_cpp]()
  if not adapter_cpp then
    vim.notify(
      "DAP: Failed locate adapter for " .. using_cpp,
      vim.log.levels.WARN
    )
    return
  end

  dap.adapters[using_cpp] = adapter_cpp

  local config_cpp = configurations[using_cpp]()
  if not config_cpp then
    vim.notify(
      "DAP: Failed locate configuration for " .. using_cpp,
      vim.log.levels.WARN
    )
    return
  end

  dap.configurations.cpp = { config_cpp }
  dap.configurations.c = { config_cpp }
  dap.configurations.rust = { config_cpp }

  local ok_dap_ui, dap_ui = pcall(require, "dapui")
  if not ok_dap_ui then
    vim.notify("DAP: Failed loading plugin nvim-dapui", vim.log.levels.WARN)
  else
    dap_ui.setup()
  end

  local ok_dap_view, dap_view = pcall(require, "dap-view")
  if not ok_dap_view then
    vim.notify("DAP: Failed loading plugin nvim-dap-view", vim.log.levels.WARN)
  else
    dap_view.setup({
      winbar = {
        controls = {
          -- enabled = true,
        },
      },
    })
  end

  local ok_dap_virtual_text, dap_virtual_text =
    pcall(require, "nvim-dap-virtual-text")
  if not ok_dap_virtual_text then
    vim.notify(
      "DAP: Failed loading plugin nvim-dap-virtual-text",
      vim.log.levels.WARN
    )
  else
    dap_virtual_text.setup({})
  end

  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  map(
    "n",
    "<F5>",
    dap.continue,
    vim.tbl_extend("force", opts, { desc = "Debug start/continue" })
  )
  map(
    "n",
    "<F10>",
    dap.step_over,
    vim.tbl_extend("force", opts, { desc = "Debug step over" })
  )
  map(
    "n",
    "<F11>",
    dap.step_into,
    vim.tbl_extend("force", opts, { desc = "Debug step into" })
  )
  map(
    "n",
    "<F12>",
    dap.step_out,
    vim.tbl_extend("force", opts, { desc = "Debug step out" })
  )
  map(
    "n",
    "<leader>xc",
    dap.continue,
    vim.tbl_extend("force", opts, { desc = "Debug start/continue" })
  )
  map(
    "n",
    "<leader>xo",
    dap.step_over,
    vim.tbl_extend("force", opts, { desc = "Debug step over" })
  )
  map(
    "n",
    "<leader>xi",
    dap.step_into,
    vim.tbl_extend("force", opts, { desc = "Debug step into" })
  )
  map(
    "n",
    "<leader>xO",
    dap.step_out,
    vim.tbl_extend("force", opts, { desc = "Debug step out" })
  )

  -- Toggle/set breakpoint
  map(
    "n",
    "<leader>b",
    dap.toggle_breakpoint,
    vim.tbl_extend("force", opts, { desc = "Toggle debug breakpoint" })
  )
  map(
    "n",
    "<leader>B",
    dap.set_breakpoint,
    vim.tbl_extend("force", opts, { desc = "Set debug breakpoint" })
  )

  -- Breakpoint navigation
  map("n", "<leader>bl", function()
    dap.list_breakpoints()
    vim.cmd("copen")
  end, vim.tbl_extend("force", opts, { desc = "List breakpoints (quickfix)" }))

  -- stack frame navigation
  map(
    "n",
    "]s",
    dap.down,
    vim.tbl_extend("force", opts, { desc = "Jump to next debug stack frame" })
  )
  map(
    "n",
    "[s",
    dap.up,
    vim.tbl_extend(
      "force",
      opts,
      { desc = "Jump to previous debug stack frame" }
    )
  )
end

return M
