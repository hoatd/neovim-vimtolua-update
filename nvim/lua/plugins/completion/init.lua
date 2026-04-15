-- lua/plugins/completion/init.lua
-- Completion engine — auto-discovered by lazy.nvim via this init.lua.
--
-- Two engines, only one enabled at a time:
--   cmp.lua      — nvim-cmp (stable, familiar) — toggle via ENABLED local
--   blink.lua    — blink.cmp (better opencode integration) — set enabled = true to activate

local M = {}
vim.list_extend(M, require("plugins.completion.cmp"))
vim.list_extend(M, require("plugins.completion.blink"))
return M
