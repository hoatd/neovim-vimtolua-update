-- Load Lua modules

require("config.settings")
require("config.keymaps")
require("config.autocmds")
require("config.plugins").setup()
require("config.ui").setup()
require("treesitter")
require("lsp")
