-- init.lua
-- Load Lua modules

require("config.options").setup()
require("config.keymaps").setup()
require("config.autocmds").setup()
require("config.plugins").setup()
require("config.ui").setup()
require("config.git").setup()
require("config.treesitter").setup()
require("config.snippets").setup()
require("config.mason").setup()
require("config.lsp").setup()
require("config.diagnostics").setup()
require("config.completion").setup()
require("config.dap").setup()
require("config.copilot").setup()
require("config.codecompanion").setup()
