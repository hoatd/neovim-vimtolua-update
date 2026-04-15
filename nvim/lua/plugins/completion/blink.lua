-- lua/plugins/completion/blink.lua
-- blink.cmp completion engine — placeholder for future migration.
-- To activate: set enabled = true here, set ENABLED = false in nvim_cmp.lua.
--
-- blink.cmp advantages over nvim-cmp for this config:
--   - Works in opencode ask prompt (respects vim.b.completion = true set by opencode.nvim)
--   - Built-in snippet, cmdline, path, buffer sources (fewer dependencies)
--   - Better performance (Rust fuzzy matching core)
--
-- Migration notes:
--   - Sources: replace cmp-* plugins with built-in source names
--   - Snippets: snippets = { preset = "luasnip" }
--   - cmp-git: switch to Kaiser-Yang/blink-cmp-git
--   - lspkind: integrate via draw.components (optional)
--   - Keymaps: translate concept-for-concept (see cmp.lua for reference)
--   - Cmdline: built-in, enabled by default
--   - Pin version = "1.*" to avoid V2 churn

return {
  {
    "saghen/blink.cmp",
    enabled = false,
    version = "1.*",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    opts = {
      -- TODO: translate full config from nvim_cmp.lua
    },
  },
}
