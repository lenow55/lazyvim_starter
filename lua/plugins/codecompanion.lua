if true then
  return {}
end

return {
  -- {
  --   "Davidyz/VectorCode",
  --   version = "*", -- optional, depending on whether you're on nightly or release
  --   build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     async_backend = "lsp", -- or "lsp"
  --     async_opts = {
  --       n_query = 2,
  --       notify = true,
  --     },
  --     -- exclude_this = true,
  --     n_query = 2,
  --     notify = true,
  --     timeout_ms = 5000,
  --     on_setup = {
  --       update = false, -- set to true to enable update when `setup` is called.
  --       lsp = false,
  --     },
  --   },
  -- },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "here api key",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "qwen/qwen3-30b-a3b:free",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.8,
                desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                validate = function(n)
                  return n >= 0 and n <= 2, "Must be between 0 and 2"
                end,
              },
              max_completion_tokens = {
                order = 3,
                mapping = "parameters",
                type = "integer",
                optional = true,
                default = nil,
                desc = "An upper bound for the number of tokens that can be generated for a completion.",
                validate = function(n)
                  return n > 0, "Must be greater than 0"
                end,
              },
              stop = {
                order = 4,
                mapping = "parameters",
                type = "string",
                optional = true,
                default = nil,
                desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                validate = function(s)
                  return s:len() > 0, "Cannot be an empty string"
                end,
              },
            },
            opts = {
              stream = true,
            },
          })
        end,
        landev_openai = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://gpt-api.lanit.dev/balancer",
              api_key = "here api key",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "Qwen/Qwen2.5-72B-Instruct-GPTQ-Int8",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.8,
                desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                validate = function(n)
                  return n >= 0 and n <= 2, "Must be between 0 and 2"
                end,
              },
              max_completion_tokens = {
                order = 3,
                mapping = "parameters",
                type = "integer",
                optional = true,
                default = nil,
                desc = "An upper bound for the number of tokens that can be generated for a completion.",
                validate = function(n)
                  return n > 0, "Must be greater than 0"
                end,
              },
              stop = {
                order = 4,
                mapping = "parameters",
                type = "string",
                optional = true,
                default = nil,
                desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                validate = function(s)
                  return s:len() > 0, "Cannot be an empty string"
                end,
              },
              -- extra_headers = {
              --   order = 5,
              --   mapping = "parameters",
              --   type = "table",
              --   optional = true,
              --   default = {
              --     langfuse_trace_user_id = "",
              --     langfuse_session_id = "",
              --   },
              --   desc = "headers for langfuse traces",
              --   validate = function(_)
              --     return true
              --   end,
              -- },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "landev_openai",
        },
        inline = {
          adapter = "landev_openai",
        },
        cmd = {
          adapter = "landev_openai",
        },
      },
      opts = {
        language = "Russian",
        log_level = "INFO",
      },
      -- extensions = {
      --   vectorcode = {
      --     opts = {
      --       add_tool = true,
      --       add_slash_command = true,
      --       -- tool_opts = {},
      --     },
      --   },
      -- },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
