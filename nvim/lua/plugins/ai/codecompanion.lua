-- lua/plugins/ai/codecompanion.lua
-- CodeCompanion: AI chat and inline assistant.
--
-- Enable: set enabled = true below.
-- Adapter defaults to copilot — requires copilot.lua enabled and signed in.
-- To use a different adapter, change the adapter fields in opts.

return {
  {
    "olimorris/codecompanion.nvim",
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local opts = {
        adapters = {
          http = {
            copilot_ghe = function()
              local _copilot_token = nil
              local _token_expires_at = 0
              local _api_url = nil
              local _available_models = nil
              local _default_model = "claude-sonnet-4.6"
              local curl = require("plenary.curl")
              local version = vim.version()
              local nvim_version = "Neovim/"
                .. version.major
                .. "."
                .. version.minor
                .. "."
                .. version.patch

              -- Read apps.json on demand — file may not exist at startup
              -- and credentials may change during the nvim session.
              local function read_apps_json()
                local p = "~/.config/github-copilot/apps.json"
                local f = io.open(vim.fn.expand(p))
                if not f then
                  return nil, nil
                end
                local ok, data = pcall(vim.json.decode, f:read("*a"))
                f:close()
                if not ok then
                  return nil, nil
                end
                for key, v in pairs(data) do
                  if v.oauth_token then
                    local host = key:match("^([^:]+)")
                    return host, v.oauth_token
                  end
                end
                return nil, nil
              end

              -- Exchange oauth token for a short-lived copilot token.
              -- Re-reads apps.json each time the copilot token expires,
              -- picking up credential or host changes automatically.
              local function get_token()
                if _copilot_token and _token_expires_at > os.time() + 60 then
                  return _copilot_token
                end
                local host, oauth_token = read_apps_json()
                if not host or not oauth_token then
                  return nil
                end
                local resp = curl.get(
                  "https://" .. host .. "/api/v3/copilot_internal/v2/token",
                  {
                    sync = true,
                    headers = {
                      Authorization = "Bearer " .. oauth_token,
                      Accept = "application/json",
                    },
                  }
                )
                if not resp or resp.status ~= 200 then
                  return nil
                end
                local ok, decoded = pcall(vim.json.decode, resp.body)
                if not ok or not decoded.token then
                  return nil
                end
                _copilot_token = decoded.token
                _token_expires_at = decoded.expires_at or 0
                _api_url = "https://copilot-api." .. host
                -- Fetch and cache available models
                local mresp = curl.get(_api_url .. "/models", {
                  sync = true,
                  headers = {
                    Authorization = "Bearer " .. _copilot_token,
                    ["Content-Type"] = "application/json",
                    ["Editor-Version"] = nvim_version,
                    ["Copilot-Integration-Id"] = "vscode-chat",
                  },
                })
                if mresp and mresp.status == 200 then
                  local mok, mdata = pcall(vim.json.decode, mresp.body)
                  if mok and mdata and mdata.data then
                    _available_models = {}
                    for _, m in ipairs(mdata.data) do
                      if not m.id:find("embedding") then
                        table.insert(_available_models, m.id)
                      end
                    end
                  end
                end
                vim.schedule(function()
                  vim.notify(
                    "copilot_ghe: host = "
                      .. host
                      .. ", model = "
                      .. _default_model,
                    vim.log.levels.INFO
                  )
                end)
                return _copilot_token
              end

              return require("codecompanion.adapters").extend(
                "openai_compatible",
                {
                  name = "copilot_ghe",
                  opts = {
                    stream = false,
                  },
                  env = {
                    -- url resolved lazily after get_token sets _api_url
                    url = function()
                      get_token()
                      return _api_url or "https://copilot-api.github.com"
                    end,
                    chat_url = "/chat/completions",
                    models_endpoint = "/models",
                    api_key = get_token,
                  },
                  headers = {
                    ["Content-Type"] = "application/json",
                    Authorization = "Bearer ${api_key}",
                    ["Editor-Version"] = nvim_version,
                    ["Copilot-Integration-Id"] = "vscode-chat",
                  },
                  schema = {
                    model = {
                      default = _default_model,
                      choices = function()
                        return _available_models or { _default_model }
                      end,
                    },
                  },
                }
              )
            end,
          },
        },
        interactions = {
          chat = {
            -- adapter = "copilot",
            adapter = "copilot_acp", -- works with my GHE
            -- adapter = "opencode", -- works with my GHE
          },
          inline = {
            -- adapter = "copilot",
            adapter = "copilot_ghe",
          },
          cmd = {
            -- adapter = "copilot",
            adapter = "copilot_ghe",
          },
          cli = {
            agent = "opencode",
            agents = {
              opencode = {
                cmd = "opencode",
                args = { "--port" },
                description = "OpenCode CLI agent",
              },
              copilot = {
                cmd = "copilot",
                args = {},
                description = "GitHub Copilot CLI agent",
              },
            },
          },
        },
      }
      require("codecompanion").setup(opts)
    end,
  },
}
