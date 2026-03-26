-- Load Lua modules

require("config.settings")
require("config.keymaps")
require("config.autocmds")

-- Load plugins
require("config.plugins").setup()

-- UI tweaks
require("config.ui")

require("treesitter")
require("lsp")
