local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- ============================================================
-- OS detection
-- ============================================================
local is_windows = wezterm.target_triple:find("windows") ~= nil

local wsl_linux_distro = "NeovimAI-Ubuntu-24.04"

config.default_prog = { "wsl.exe", "-d", wsl_linux_distro, "--", "bash", "-l" }

-- ============================================================
-- Shell definitions — launch_menu only
-- ============================================================
if is_windows then
  config.launch_menu = {
    {
      label = "Command Prompt",
      args = { "cmd.exe" },
    },
    {
      label = "PowerShell",
      args = { "pwsh.exe" },
    },
    {
      label = "Developer Command Prompt for VS 2022 (x64)",
      args = {
        "cmd.exe",
        "/k",
        "C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\\Common7\\Tools\\VsDevCmd.bat",
        "-startdir=none",
        "-arch=x64",
        "-host_arch=x64",
      },
    },
    {
      label = "Developer PowerShell for VS 2022 (x64)",
      args = {
        "pwsh.exe",
        "-NoExit",
        "-Command",
        -- Import-Module path has no spaces issues; Enter-VsDevShell uses the
        -- instance ID. The -Command string is passed as a single argv element
        -- by WezTerm so no extra shell quoting is needed — use plain single quotes.
        "Import-Module 'C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll'; "
          .. "Enter-VsDevShell 6e656755 -SkipAutomaticLocation -DevCmdArguments '-arch=x64 -host_arch=x64'",
      },
    },
    {
      label = "WSL/Ubuntu Bash (Default)",
      -- args = { "wsl.exe", "-d", wsl_linux_distro, "--", "bash", "-l" },
      args = config.default_prog,
    },
    {
      label = "WSL/Ubuntu Tmux",
      args = { "wsl.exe", "-d", wsl_linux_distro, "--", "tmux" },
    },
    {
      label = "WSL/Ubuntu Zellij",
      args = {
        "wsl.exe",
        "-d",
        wsl_linux_distro,
        "--",
        "bash",
        "-lc",
        "exec zellij",
      },
    },
  }
else
  config.launch_menu = {
    { label = "bash", args = { "bash", "-l" } },
    { label = "zsh", args = { "zsh", "-l" } },
  }
end
-- ============================================================
-- Performance
-- ============================================================
config.front_end = "OpenGL"
config.max_fps = 60
config.animation_fps = 60
config.scrollback_lines = 3500

-- ============================================================
-- Appearance
-- ============================================================
local fonts = {
  jetbrains = wezterm.font("JetBrainsMono Nerd Font Mono"),
  caskaydia = wezterm.font("CaskaydiaMono Nerd Font Mono"),
}
config.font = fonts.jetbrains
config.font_size = 12
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- ============================================================
-- Catppuccin color scheme
config.color_scheme = "Catppuccin Latte" -- Latte, Macchiato, Mocha, Frappe
-- ============================================================
-- Kitty keyboard protocol — fixes Ctrl/Alt combos in Neovim
-- ============================================================
config.enable_kitty_keyboard = true
config.allow_win32_input_mode = false
config.enable_csi_u_key_encoding = false
-- ============================================================
-- Keymaps
-- ============================================================
config.keys = {
  -- CTRL+SHIFT+ALT+t — fuzzy launcher to pick a shell for this tab only
  -- (CTRL+SHIFT+t is the built-in WezTerm default for a plain new tab)
  {
    key = "t",
    mods = "CTRL|SHIFT|ALT",
    action = wezterm.action.ShowLauncherArgs({
      flags = "FUZZY|LAUNCH_MENU_ITEMS",
      title = "Select shell",
    }),
  },
  -- -- Pane navigation: WezTerm-level CTRL+hjkl fallback for use outside Neovim.
  -- -- Inside Neovim, wezterm.nvim owns these keys and calls the WezTerm RPC
  -- -- directly — WezTerm never sees them when Neovim is focused, so no conflict.
  -- {
  --   key = "h",
  --   mods = "CTRL",
  --   action = wezterm.action.ActivatePaneDirection("Left"),
  -- },
  -- {
  --   key = "j",
  --   mods = "CTRL",
  --   action = wezterm.action.ActivatePaneDirection("Down"),
  -- },
  -- {
  --   key = "k",
  --   mods = "CTRL",
  --   action = wezterm.action.ActivatePaneDirection("Up"),
  -- },
  -- {
  --   key = "l",
  --   mods = "CTRL",
  --   action = wezterm.action.ActivatePaneDirection("Right"),
  -- },
}
return config
