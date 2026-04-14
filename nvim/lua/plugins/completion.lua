-- lua/plugins/completion.lua
-- Completion engine, all sources, snippet bridge, and icon formatting.

return {
  -- ============================================================
  -- nvim-cmp: completion engine
  -- ============================================================
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "petertriho/cmp-git",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            -- Use LuaSnip; fall back to native Neovim snippets
            if luasnip then
              luasnip.lsp_expand(args.body)
            else
              vim.snippet.expand(args.body)
            end
          end,
        },

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        }),

        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            },
          }),
        },

        -- Bordered completion and documentation windows (uncomment to enable)
        -- window = {
        --   completion = cmp.config.window.bordered({
        --     winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel",
        --     border = "rounded",
        --   }),
        --   documentation = cmp.config.window.bordered({
        --     winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder",
        --     border = "rounded",
        --   }),
        -- },

        -- Custom entry view (uncomment to enable)
        -- view = {
        --   entries = {
        --     name = "custom",           -- "custom" | "wildmenu" | "native"
        --     selection_order = "near_cursor",
        --   },
        -- },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          -- Tab / S-Tab: snippet jump + completion navigation (uncomment to enable)
          -- ["<Tab>"] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   elseif luasnip.expandable() then
          --     luasnip.expand()
          --   elseif luasnip.locally_jumpable(1) then
          --     luasnip.jump(1)
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
          -- ["<S-Tab>"] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.locally_jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { "i", "s" }),
        }),

        experimental = {
          ghost_text = true, -- inline completion preview
        },
      })

      -- --------------------------------------------------------
      -- cmp-git: Git commit / PR completion source
      -- --------------------------------------------------------
      require("cmp_git").setup({})

      -- --------------------------------------------------------
      -- Cmdline sources
      -- --------------------------------------------------------

      -- Search: buffer words
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Command: path + cmdline
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },

  -- Sources (loaded as dependencies of nvim-cmp above, listed here for clarity)
  { "hrsh7th/cmp-nvim-lsp", enabled = true, lazy = true },
  { "hrsh7th/cmp-buffer", enabled = true, lazy = true },
  { "hrsh7th/cmp-path", enabled = true, lazy = true },
  { "hrsh7th/cmp-cmdline", enabled = true, lazy = true },
  { "petertriho/cmp-git", enabled = true, lazy = true, dependencies = { "nvim-lua/plenary.nvim" } },
  { "saadparwaiz1/cmp_luasnip", enabled = true, lazy = true },
  { "onsails/lspkind.nvim", enabled = true, lazy = true },
}
