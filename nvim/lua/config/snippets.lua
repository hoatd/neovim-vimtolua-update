-- lua/config/snippets.lua

local M = {}

function M.setup()

  -- Luasnip
  local ok_luasnip, luasnip = pcall(require, "luasnip")
  if ok_luasnip then
    luasnip.setup({
      history = true, -- Remember snippet history so you can jump back
      update_events = "TextChanged,TextChangedI", -- Update dynamic snippets while typing
      enable_autosnippets = true, -- Enable autosnippets (e.g. date, etc.)
      region_check_events = "InsertEnter", -- Optional: better snippet cleanup
      delete_check_events = "InsertLeave",
    })

    -- Load friendly-snippets (VSCode style snippets for many languages)
    local ok_friendly, friendly = pcall(require, "luasnip.loaders.from_vscode")
    if ok_friendly then
      friendly.lazy_load()
    else
      vim.notify(
        "Plugin: friendly-snippets (luasnip.loaders.from_vscode) failed setting up: "
          .. (friendly or "unknown error"),
        vim.log.levels.WARN
      )
    end
  else
    vim.notify(
      "Plugin: Luasnip failed setting up: " .. (luasnip or "unknown error"),
      vim.log.levels.WARN
    )
  end

end

return M
