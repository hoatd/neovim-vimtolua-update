-- lua/config/completion.lua

local M = {}

function M.setup()
  -- nvim-cmp.
  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp then
    local ok_luasnip, luasnip = pcall(require, "luasnip")
    local ok_lspkind, lspkind = pcall(require, "lspkind")
    cmp.setup({
      snippet = {
        expand = function(args)
          -- For `luasnip` users.
          if ok_luasnip then
            require("luasnip").lsp_expand(args.body)
          else
            vim.notify(
              "Plugin: Luasnip failed setting up: "
                .. (luasnip or "unknown error"),
              vim.log.levels.WARN
            )
          end
          -- For native neovim snippets
          vim.snippet.expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },
        { name = "path" },
        { name = "cmdline" },
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
      window = {
        completion = cmp.config.window.bordered({
          winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel",
          border = "rounded",
        }),
        documentation = cmp.config.window.bordered({
          winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder",
          border = "rounded",
        }),
      },
      -- view = {
      --   entries = {
      --     name = "custom", -- can be "custom", "wildmenu" or "native"
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
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item

        -- Tab / S-Tab for snippet and completion navigation
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      experimental = {
        ghost_text = true, -- Show inline preview
      },
    })
    -- Set configuration for specific filetype.
    -- gitcommit
    require("cmp_git").setup({})
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({
        { name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
      }, {
        { name = "buffer" },
      }),
    })
    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
    })
  else
    vim.notify(
      "Plugin: Nvim-cmp failed setting up: " .. (cmp or "unknown error"),
      vim.log.levels.WARN
    )
  end
end

function M.get_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if not ok_cmp_lsp then
    return cmp_lsp.default_capabilities()
  else
    return vim.lsp.protocol.make_client_capabilities()
  end
end

return M
