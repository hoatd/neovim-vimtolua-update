-- Load Lua modules

require("config.options")
require("config.keymaps")
require("config.autocmds").setup()
require("config.plugins").setup()
require("config.ui").setup()
require("config.git").setup()
require("config.diagnostics").setup()
require("config.treesitter").setup()
require("config.snipets").setup()
require("config.completion").setup()
require("config.lsp").setup()
