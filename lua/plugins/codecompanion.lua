if true then
  return {}
end

local parse_reasoning = function(data)
  local extra = data.extra
  if extra and extra.reasoning_content and extra.reasoning_content ~= "" then
    data.output.reasoning = data.output.reasoning or {}
    data.output.reasoning.content = extra.reasoning_content
  end
  if extra and extra.reasoning and extra.reasoning ~= "" then
    data.output.reasoning = data.output.reasoning or {}
    data.output.reasoning.content = extra.reasoning
  end
  if data.output.content == "" then
    data.output.content = nil
  end
  return data
end

local metadata_uid = {
  order = 11,
  mapping = "parameters",
  type = "string",
  desc = "ID пользователя для langfuse",
  default = "IANovikov@lanit.ru",
}

local landev_url = "https://dev02-lb.gpt.dks.lanit.ru/v1/chat/completions"
-- local landev_url = "http://litellm.dev02.svc.cluster.local:4000/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters.http").extend("gemini", {})
          end,
          local_landev = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            adapter.url = landev_url
            adapter.env = {
              api_key = "LANDEV_API_KEY",
            }
            adapter.opts = {
              stream = true,
              tools = true,
              vision = true,
            }
            ---@param self CodeCompanion.HTTPAdapter
            ---@param data table The request payload built by the chat buffer
            ---@return table|nil
            adapter.handlers.set_body = function(self, data)
              if self.opts and self.opts.session_id then
                return { metadata = { session_id = self.opts.session_id } }
              end

              if data and data.session_id then
                return { metadata = { session_id = data.session_id } }
              end
            end
            adapter.schema["metadata.trace_user_id"] = metadata_uid
            adapter.schema.model = {
              order = 1,
              mapping = "parameters",
              type = "enum",
              desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
              default = "local/google/gemma-4-31B-it",
              choices = {
                ["local/google/gemma-4-31B-it"] = {
                  formatted_name = "Gemma-4-32B",
                  opts = { can_reason = true, has_vision = false },
                },
                ["local/Qwen/Qwen3-32B"] = {
                  formatted_name = "Qwen3-32B",
                  opts = { can_reason = false, has_vision = false },
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

            adapter.handlers.parse_message_meta = function(self, data)
              data = parse_reasoning(data)
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
        -- opts = {
        --   date_format = "%Y-%m-%d",
        -- },
        background = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
          },
        },
        chat = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
          },
          tools = {
            opts = {
              system_prompt = {
                enabled = false,
              },
            },
          },
        },
        inline = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
          },
        },
        cmd = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
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
    },
  },
}
