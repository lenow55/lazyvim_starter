if true then
  return {}
end

local metadata_uid = {
  order = 11,
  mapping = "parameters",
  type = "string",
  desc = "ID пользователя для langfuse",
  default = "IANovikov@lanit.ru",
}
local metadata_sid = {
  order = 12,
  mapping = "parameters",
  type = "string",
  desc = "ID сессии для langfuse",
  default = "f685bad1-3f92-4e8b-bd99-95c791500000",
}
local landev_api = "sk-key"
local landev_url = "https://gpt-lb-dev01.landev.dks.lanit.ru/v1/chat/completions"
-- local landev_url = "http://localhost:4000/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters.http").extend("gemini", {
              env = {
                api_key = "api_key",
              },
            })
          end,
          gpt5_landev = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai_responses", {})
            adapter.url = "https://gpt-lb-dev01.landev.dks.lanit.ru/v1/responses"
            adapter.env = {
              api_key = landev_api,
            }
            adapter.parameters = {
              store = false,
            }

            adapter.opts = {
              stream = false,
            }
            adapter.schema.model = {
              order = 1,
              mapping = "parameters",
              type = "enum",
              desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
              ---@type string|fun(): string
              default = "openai/gpt-5",
              choices = {
                ["openai/gpt-5"] = {
                  formatted_name = "GPT 5",
                  opts = { has_function_calling = true, has_vision = true, can_reason = false },
                },
                -- ["openai/gpt-5-mini"] = {
                --   formatted_name = "GPT 5 Mini",
                --   opts = { has_vision = true, can_reason = true },
                -- },
                -- ["openai/gpt-5-nano"] = {
                --   formatted_name = "GPT 5 Nano",
                --   opts = { has_vision = true, can_reason = true },
                -- },
                ["openai/gpt-5-codex"] = {
                  formatted_name = "GPT 5 Codex",
                  opts = { has_function_calling = true, has_vision = true, can_reason = true },
                },
                -- ["openai/gpt-5-pro"] = {
                --   formatted_name = "GPT 5 Pro",
                --   opts = { has_vision = true, can_reason = true },
                -- },
              },
            }
            adapter.schema["reasoning.summary"].default = nil
            adapter.schema["metadata.trace_user_id"] = metadata_uid
            adapter.schema["metadata.session_id"] = metadata_sid
            return adapter
          end,
          openrouter_landev = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            adapter.url = landev_url
            adapter.env = {
              api_key = landev_api,
            }
            adapter.parameters = {
              store = false,
            }
            adapter.schema.model = {
              order = 1,
              mapping = "parameters",
              type = "enum",
              desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
              default = "openrouter/anthropic/claude-sonnet-4",
              choices = {
                ["openrouter/anthropic/claude-sonnet-4.5"] = {
                  formatted_name = "Claude Sonnet 4.5",
                  opts = { has_function_calling = false, can_reason = true, has_vision = true },
                },
                ["openrouter/anthropic/claude-haiku-4.5"] = {
                  formatted_name = "Claude Haiku 4.5",
                  opts = { has_function_calling = false, can_reason = true, has_vision = true },
                },

                ["openrouter/anthropic/claude-sonnet-4"] = {
                  formatted_name = "Claude Sonnet 4",
                  opts = { has_function_calling = false, can_reason = true, has_vision = true },
                },
                ["openrouter/anthropic/claude-3.7-sonnet"] = {
                  formatted_name = "Claude 3.7 Sonnet",
                  opts = {
                    has_function_calling = false,
                    can_reason = true,
                    has_vision = true,
                    has_token_efficient_tools = true,
                  },
                },
                ["openrouter/anthropic/claude-3.5-sonnet"] = {
                  formatted_name = "Claude Sonnet 3.5",
                  opts = { has_function_calling = true, has_vision = true },
                },
                ["openrouter/qwen/qwen3-coder"] = {
                  formatted_name = "Qwen3-Coder",
                  opts = { has_function_calling = true, can_reason = true, has_vision = false },
                },
              },
            }
            adapter.schema["reasoning.effort"] = adapter.schema.reasoning_effort
            adapter.schema.reasoning_effort = nil
            adapter.schema["metadata.trace_user_id"] = metadata_uid
            adapter.schema["metadata.session_id"] = metadata_sid

            adapter.handlers.parse_message_meta = function(self, data)
              local extra = data.extra
              if extra.reasoning_content then
                data.output.reasoning = { content = extra.reasoning_content }
                if data.output.content == "" then
                  data.output.content = nil
                end
              end
              return data
            end
            return adapter
          end,
          local_landev = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            adapter.url = landev_url
            adapter.env = {
              api_key = landev_api,
            }
            adapter.parameters = {
              store = false,
            }
            adapter.schema.model = {
              order = 1,
              mapping = "parameters",
              type = "enum",
              desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
              default = "local/Qwen/Qwen3-32B",
              choices = {
                ["Qwen/Qwen2.5-72B-Instruct-GPTQ-Int8"] = {
                  formatted_name = "Qwen2.5-72B",
                  opts = { has_function_calling = false, can_reason = true, has_vision = false },
                },
                ["local/Qwen/Qwen3-32B"] = {
                  formatted_name = "Qwen3-32B",
                  opts = { has_function_calling = false, can_reason = false, has_vision = false },
                },
              },
            }
            adapter.schema["chat_template_kwargs.enable_thinking"] = {
              order = 2,
              mapping = "parameters",
              type = "boolean",
              desc = "Флаг рассуждений",
              default = true,
              optional = true,
              condition = function(self)
                local model = self.schema.model.default
                if type(model) == "function" then
                  model = model()
                end
                local choices = self.schema.model.choices
                if type(choices) == "function" then
                  choices = choices(self)
                end
                if choices and choices[model] and choices[model].opts and choices[model].opts.can_reason then
                  return true
                end
                return false
              end,
            }
            adapter.schema.reasoning_effort = nil
            adapter.schema["metadata.trace_user_id"] = metadata_uid
            adapter.schema["metadata.session_id"] = metadata_sid

            adapter.handlers.parse_message_meta = function(self, data)
              local extra = data.extra
              if extra.reasoning_content then
                data.output.reasoning = { content = extra.reasoning_content }
                if data.output.content == "" then
                  data.output.content = nil
                end
              end
              return data
            end
            return adapter
          end,
          opts = {
            allow_insecure = true,
            show_presets = false,
            show_model_choices = true,
          },
        },
        acp = {
          opts = {
            show_presets = false,
            show_model_choices = true,
          },
        },
      },
      interactions = {
        background = {
          adapter = {
            name = "openrouter_landev",
            model = "openrouter/anthropic/claude-sonnet-4",
          },
        },
        chat = {
          adapter = {
            name = "local_landev",
            model = "local/Qwen/Qwen3-32B",
          },
        },
        inline = {
          adapter = {
            name = "openrouter_landev",
            model = "openrouter/anthropic/claude-sonnet-4",
          },
        },
        cmd = {
          adapter = {
            name = "local_landev",
            model = "local/Qwen/Qwen3-32B",
          },
        },
      },
      opts = {
        language = "Russian",
        log_level = "INFO",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
