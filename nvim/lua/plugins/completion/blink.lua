-- lua/plugins/completion/blink.lua
-- blink.cmp completion engine
-- To activate: set enabled = true here, set disable in cmp.lua.
--
-- Migration notes:
--   - cmp-git: switch to Kaiser-Yang/blink-cmp-git
--   - lspkind: integrate via draw.components (optional)

return {
  {
    "saghen/blink.cmp",
    enabled = true,
    version = "1.*",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      { "fang2hou/blink-copilot" },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<A-1>"] = {
          function(cmp)
            cmp.accept({ index = 1 })
          end,
        },
        ["<A-2>"] = {
          function(cmp)
            cmp.accept({ index = 2 })
          end,
        },
        ["<A-3>"] = {
          function(cmp)
            cmp.accept({ index = 3 })
          end,
        },
        ["<A-4>"] = {
          function(cmp)
            cmp.accept({ index = 4 })
          end,
        },
        ["<A-5>"] = {
          function(cmp)
            cmp.accept({ index = 5 })
          end,
        },
        ["<A-6>"] = {
          function(cmp)
            cmp.accept({ index = 6 })
          end,
        },
        ["<A-7>"] = {
          function(cmp)
            cmp.accept({ index = 7 })
          end,
        },
        ["<A-8>"] = {
          function(cmp)
            cmp.accept({ index = 8 })
          end,
        },
        ["<A-9>"] = {
          function(cmp)
            cmp.accept({ index = 9 })
          end,
        },
        ["<A-0>"] = {
          function(cmp)
            cmp.accept({ index = 10 })
          end,
        },
        ["<Tab>"] = {
          function(cmp)
            -- Inject Copilot NES first
            local copilot_lsp_nes_loaded = package.loaded["copilot-lsp.nes"]
            if
              copilot_lsp_nes_loaded
              and vim.b[vim.api.nvim_get_current_buf()].nes_state
            then
              cmp.hide()
              if not copilot_lsp_nes_loaded.walk_cursor_start_edit() then
                copilot_lsp_nes_loaded.apply_pending_nes()
                copilot_lsp_nes_loaded.walk_cursor_end_edit()
              end
              return true
            end
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
      },
      completion = {
        ghost_text = { enabled = true, show_without_selection = true },
        documentation = { auto_show = true },
        list = {
          selection = {
            preselect = true, -- auto-highlight first item when menu opens
            auto_insert = false, -- don't insert text until you explicitly accept
          },
        },
        menu = {
          draw = {
            columns = {
              { "item_idx" },
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
            },
            components = {
              item_idx = {
                text = function(ctx)
                  return ctx.idx == 10 and "0"
                    or ctx.idx >= 10 and " "
                    or tostring(ctx.idx)
                end,
                highlight = "BlinkCmpItemIdx", -- optional to change its color
              },
            },
          },
        },
      },
      signature = { enabled = true },
      snippets = { preset = "luasnip" },
      sources = {
        -- default = { "lsp", "path", "snippets", "buffer" },
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          buffer = {
            opts = {
              -- get all buffers, even ones like neo-tree
              get_bufnrs = vim.api.nvim_list_bufs,
              -- or (recommended) filter to only "normal" buffers
              -- get_bufnrs = function()
              --   return vim.tbl_filter(function(bufnr)
              --     return vim.bo[bufnr].buftype == ''
              --   end, vim.api.nvim_list_bufs())
              -- end
            },
          },
          cmdline = {
            -- ignores cmdline completions when executing shell commands
            enabled = function()
              return vim.fn.getcmdtype() ~= ":"
                or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
            end,
          },
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
