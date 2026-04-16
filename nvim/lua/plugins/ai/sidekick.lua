-- lua/plugins/ai/sidekick.lua
-- sidekick.nvim: NES UI + CLI tools (Zellij mux backend).
--
-- Works standalone; NES and copilot status are auto-enabled only when
-- copilot.lua is configured and enabled in the lazy spec.

return {
  {
    "folke/sidekick.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      -- Check lazy config (not package.loaded) so the result is correct
      -- regardless of whether copilot has been loaded yet.
      local has_copilot = false
      local ok_lazy_config, lazy_config = pcall(require, "lazy.core.config")
      if ok_lazy_config then
        local spec_copilot = lazy_config.plugins["zbirenbaum/copilot.lua"]
        has_copilot = spec_copilot ~= nil and spec_copilot.enabled ~= false
      else
        vim.schedule(function()
          vim.notify(
            "Sidekick: Failed loading lazy config for determining Copilot state",
            vim.log.levels.WARN
          )
        end)
      end

      require("sidekick").setup({
        nes = { enabled = has_copilot },
        cli = {
          mux = {
            backend = "zellij",
            enabled = true,
            create = "terminal",
          },
        },
        copilot = {
          status = { enabled = has_copilot },
        },
      })

      -- Apply / navigate the active Next Edit Suggestion.
      -- <M-p> is a no-op when no suggestion is active.
      vim.keymap.set({ "n", "i" }, "<M-p>", function()
        require("sidekick").nes_jump_or_apply()
      end, { desc = "NES: goto / apply next edit suggestion" })
    end,
  },
}
