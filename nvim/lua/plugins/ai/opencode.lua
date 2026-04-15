-- lua/plugins/ai/opencode.lua
-- Opencode: Neovim integration for a running opencode instance.
--
-- Enable: set enabled = true below.

return {
  -- snacks.nvim: enhances opencode ask() and select() UI
  -- optional dep in opencode spec below uses this if present
  {
    "folke/snacks.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
  },
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    enabled = true,
    dependencies = {
      {
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {}, -- Enhances `ask()`
          picker = { -- Enhances `select()`
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      require("opencode")
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        lsp = {
          enabled = true,
        },
      }

      vim.o.autoread = true -- Required for `opts.events.reload`


      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll opencode down" })

      -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
      vim.keymap.set(
        "n",
        "+",
        "<C-a>",
        { desc = "Increment under cursor", noremap = true }
      )
      vim.keymap.set(
        "n",
        "-",
        "<C-x>",
        { desc = "Decrement under cursor", noremap = true }
      )
    end,
  },
}
