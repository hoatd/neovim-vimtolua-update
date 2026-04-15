-- lua/plugins/ai/init.lua
-- AI plugin groups — auto-discovered by lazy.nvim via this init.lua.
--
-- Three independent stacks, each in its own file:
--   copilot.lua      — copilot.lua + copilot-lsp + sidekick (enable all three together)
--   codecompanion.lua — codecompanion (standalone, uses copilot as adapter by default)
--   opencode.lua     — opencode.nvim (requires external opencode --port process)

local M = {}
vim.list_extend(M, require("plugins.ai.copilot"))
vim.list_extend(M, require("plugins.ai.codecompanion"))
vim.list_extend(M, require("plugins.ai.opencode"))
return M
