-- lua/plugins/ui.lua
-- Visual theme stack: colorscheme, statusline, tabline.

return {
  -- ============================================================
  -- Dracula colorscheme
  -- priority = 1000 ensures it loads before all other plugins
  -- ============================================================
  {
    "Mofiqul/dracula.nvim",
    enabled = true,
    priority = 1000,
    lazy = false,
    config = function()
      -- --------------------------------------------------------
      -- Dracula-specific highlight overrides
      -- --------------------------------------------------------
      local function highlights_dracula()
        if vim.g.colors_name ~= "dracula" then
          return
        end

        local hl = vim.api.nvim_set_hl

        hl(0, "PmenuSel", { bg = "#44475a", fg = "#ffffff" })

        -- Base diagnostic colors
        hl(0, "DiagnosticError", { fg = "#ff5555", bold = true })
        hl(0, "DiagnosticWarn", { fg = "#f1fa8c", bold = true })
        hl(0, "DiagnosticInfo", { fg = "#8be9fd" })
        hl(0, "DiagnosticHint", { fg = "#bd93f9" })

        -- Virtual text (italic + slightly softer for inline text)
        hl(0, "DiagnosticVirtualTextError", { fg = "#ff5555", italic = true, nocombine = true })
        hl(0, "DiagnosticVirtualTextWarn", { fg = "#f1fa8c", italic = true, nocombine = true })
        hl(0, "DiagnosticVirtualTextInfo", { fg = "#8be9fd", italic = true, nocombine = true })
        hl(0, "DiagnosticVirtualTextHint", { fg = "#bd93f9", italic = true, nocombine = true })

        -- Underline colors
        hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5555" })
        hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#f1fa8c" })
        hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#8be9fd" })
        hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#bd93f9" })

        -- Tabline
        hl(0, "TabLineSel", { bg = "#44475a", fg = "#f8f8f2" })
        hl(0, "TabLine", { bg = "#282a36", fg = "#6272a4" })
        hl(0, "TabLineFill", { bg = "#1e1f29" })

        -- Gitsigns
        hl(0, "GitSignsAdd", { fg = "#50fa7b" })
        hl(0, "GitSignsChange", { fg = "#f1fa8c" })
        hl(0, "GitSignsDelete", { fg = "#ff5555" })

        -- nvim-tree
        hl(0, "NvimTreeNormal", { bg = "#1e1f29" })
        hl(0, "NvimTreeFolderName", { fg = "#8be9fd" })
        hl(0, "NvimTreeOpenedFolderName", { fg = "#8be9fd", bold = true })
        hl(0, "NvimTreeGitDirty", { fg = "#f1fa8c" })
      end

      require("dracula").setup({
        show_end_of_buffer = true,
        transparent_bg = true,
        italic_comment = true,
      })
      vim.opt.termguicolors = true

      -- Register before setting colorscheme so the autocmd fires on
      -- vim.cmd.colorscheme() below — no need for a separate explicit call.
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = require("utils").augroup("colors"),
        pattern = "*",
        callback = highlights_dracula,
        desc = "Highlight overrides",
      })

      vim.cmd.colorscheme("dracula")
    end,
  },

  -- ============================================================
  -- Lualine statusline
  -- ============================================================
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    dependencies = {
      "Mofiqul/dracula.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        theme = "dracula-nvim",
      },
      sections = {
        lualine_x = {
          -- opencode statusline (uncomment when opencode is enabled in ai.lua)
          -- require("opencode").statusline,
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    },
  },

  -- ============================================================
  -- Tabby tabline
  -- ============================================================
  {
    "nanozuki/tabby.nvim",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      preset = "active_wins_at_tail",
    },
  },
}
