# AGENTS.md

## What this repo is

Personal Neovim config migrated from Vimscript to Lua. Uses `folke/lazy.nvim` for plugin management. No build pipeline, no test suite, no CI.

The only external dev tool is `stylua` (installed via Cargo: `~/.cargo/bin/stylua`).

---

## Formatting

```bash
# Format all Lua files
stylua nvim/

# Check without modifying (CI-equivalent)
stylua --check nvim/

# Format a single file
stylua nvim/lua/config/options.lua
```

Config (`stylua.toml` at repo root):
- `indent_type = "Spaces"`, `indent_width = 2`, `column_width = 80`
- `quote_style = "AutoPreferDouble"`

There is no linter (`luacheck`/`selene`), no pre-commit hook, and no task runner.

---

## Directory layout

```
nvim/
  init.lua              # Entrypoint — bootstraps lazy.nvim, calls config.* setup()
  lazy-lock.json        # Plugin lockfile — commit when plugins change
  lua/
    utils.lua           # Shared helpers: augroup(), apply_vim_options(), ensure_dirs_exist()
    config/             # Pure Neovim stdlib — no plugin dependency
      options.lua
      keymaps.lua
      autocmds.lua
      diagnostics.lua
    plugins/            # One file per plugin group, each returns lazy.nvim spec tables
      ai/               # Subdirectory — auto-discovered via ai/init.lua
        init.lua        # Dispatcher: vim.list_extend from copilot, codecompanion, opencode
        copilot.lua     # copilot.lua + copilot-lsp + sidekick.nvim
        codecompanion.lua
        opencode.lua    # opencode.nvim + snacks.nvim backend
```

**Subdirectory discovery:** lazy.nvim only auto-discovers a subdirectory when it contains `init.lua`. Plain `.lua` files in subdirs without `init.lua` are ignored.

---

## Boot order (matters)

`init.lua` runs these **before** lazy.nvim loads any plugin:

1. `require("config.options").setup()`
2. `require("config.keymaps").setup()`
3. `require("config.autocmds").setup()`
4. `require("config.diagnostics").setup()`
5. lazy.nvim bootstrap → `require("lazy").setup("plugins", ...)`

Code in `lua/config/` must not `require()` any plugin. Plugin-dependent setup belongs in `lua/plugins/` `config` functions or `on_attach` callbacks.

---

## Plugin conventions

- `lua/plugins/` files are auto-discovered by lazy.nvim — every `.lua` file must return a valid spec table.
- Use `enabled = true/false` on spec entries; do **not** comment specs out.
- All keymaps must have a `desc` field for which-key.
- Use `pcall(require, ...)` guards on optional plugin requires.
- Use `vim.notify()` for runtime messages, never `print()`.

---

## LSP: non-standard API

This config uses the **Neovim 0.11+ native API** — not the traditional pattern:

```lua
-- Correct pattern used here
vim.lsp.config("lua_ls", { ... })
vim.lsp.enable("lua_ls")

-- NOT used here (legacy lspconfig pattern)
require("lspconfig").lua_ls.setup({ ... })
```

`mason-lspconfig` is configured with `automatic_enable = false`. Servers are enabled explicitly in `lsp.lua`.

---

## Treesitter: non-standard branch

`nvim-treesitter` is pinned to the `main` branch (not `master`). The API differs from most tutorials:

```lua
-- Correct (main branch)
require("nvim-treesitter").install(parsers)

-- NOT the legacy API
require("nvim-treesitter.configs").setup({ ... })
```

Treesitter is activated per-buffer via autocmds, not globally. Large-file guards kick in at 5 MB (disables swap/undo) and 20,000 lines (disables treesitter/folding/signs).

---

## AI plugins

AI integrations live in `lua/plugins/ai/` (subdirectory). Each file is a separate lazy.nvim spec:

- `ai/copilot.lua` — copilot.lua + copilot-lsp + sidekick.nvim; targets GHE endpoint (`https://straumann.ghe.com/`), `enabled = false`
- `ai/codecompanion.lua` — codecompanion with copilot adapter, `enabled = false`
- `ai/opencode.lua` — opencode.nvim + snacks.nvim terminal backend, **`enabled = true`**

To enable copilot or codecompanion: set `enabled = true` in the respective file.

---

## Notable options that differ from defaults

- **Leader:** `,` (both `mapleader` and `maplocalleader`)
- **`gdefault = true`** — `:s` replaces all occurrences without `/g`
- **`clipboard = "unnamedplus"`** — system clipboard always active
- **Tabs:** 4 spaces globally, overridden to **2 spaces** for `lua`, `vim`, `json`, `html`, `javascript` via `FileType` autocmd (matches StyLua)
- **netrw disabled** — nvim-tree is used instead
- **Keyboard layout toggle:** `vim.g.keyboard_layout = "de"` remaps `ü`→`[` and `+`→`]`

---

## Lockfile

`nvim/lazy-lock.json` pins all 37 plugins. Update it when adding or changing plugins and commit the result.

---

## No tests

There are no tests, no `Makefile`, no CI workflows. The only automated check is `stylua --check nvim/`.
