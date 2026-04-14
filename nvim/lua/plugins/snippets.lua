-- lua/plugins/snippets.lua
-- Snippet engine and snippet collection.
-- LuaSnip is also consumed as a dependency by completion.lua.

return {
  -- ============================================================
  -- LuaSnip: snippet engine
  -- ============================================================
  {
    "L3MON4D3/LuaSnip",
    enabled = true,
    config = function()
      require("luasnip").setup({
        history = true, -- remember snippet history so you can jump back
        update_events = "TextChanged,TextChangedI", -- update dynamic snippets while typing
        enable_autosnippets = true, -- enable autosnippets (e.g. date expansions)
        region_check_events = "InsertEnter", -- better snippet cleanup
        delete_check_events = "InsertLeave",
      })

      -- Load VSCode-style snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- ============================================================
  -- friendly-snippets: curated VSCode snippet collection
  -- Loaded lazily by LuaSnip via from_vscode.lazy_load()
  -- ============================================================
  {
    "rafamadriz/friendly-snippets",
    enabled = true,
    lazy = true,
  },
}
