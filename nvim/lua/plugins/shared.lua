-- lua/plugins/shared.lua
-- Shared dependencies: libraries, icons, async helpers.
-- These are consumed by other plugins; most load lazily.

return {
  -- Lua helper library (required by many plugins)
  {
    "nvim-lua/plenary.nvim",
    enabled = true,
    lazy = true,
  },

  -- Asynchronous IO library (required by nvim-dap-ui and others)
  {
    "nvim-neotest/nvim-nio",
    enabled = true,
    lazy = true,
  },

  -- Lua-based icon provider (faster than nvim-web-devicons alone)
  {
    "nvim-mini/mini.icons",
    enabled = true,
    opts = {},
  },

  -- File type icons (used by nvim-tree, lualine, tabby, etc.)
  {
    "nvim-tree/nvim-web-devicons",
    enabled = true,
    opts = {
      default = true,
    },
  },
}
