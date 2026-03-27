-- Load Lua modules

require("config.settings")
require("config.keymaps")
require("config.autocmds").setup()
require("config.plugins").setup()
require("config.ui").setup()
require("config.treesitter").setup()
require("config.lsp").setup()
