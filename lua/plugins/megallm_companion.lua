-- if true then
--   return {}
-- end

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

local megallm_url = "http://megallm:8777/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          megallm = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            local adapter_utils = require("codecompanion.adapters.utils")
            adapter.url = megallm_url
            adapter.env = {
              api_key = "EMPTY",
            }
            ---@param self CodeCompanion.HTTPAdapter
            ---@return table|nil
            local function model_choices(self)
              local model = self.schema.model.choices[self.schema.model.default]
              return model and model.opts or nil
            end

            ---@param self CodeCompanion.HTTPAdapter
            ---@param parameter string
            ---@return boolean
            local function model_supports(self, parameter)
              local model = self.schema.model.choices[self.schema.model.default]
              if not model then
                return false
              end
              return model.opts.supported_parameters[parameter] or false
            end
            ---Устанавливаем id сессии для работы litellm
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
            adapter.schema = {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
                default = "Qwen/Qwen3.8-27B-FP8",
                choices = {
                  ["google/Gemma-4-31B-it"] = {
                    formatted_name = "Gemma-4-31B",
                    meta = { context_window = 40000 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = false,
                      supported_parameters = {},
                    },
                  },
                  ["Qwen/Qwen3.8-27B-FP8"] = {
                    formatted_name = "Qwen3.8-27B",
                    meta = { context_window = 200000 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = false,
                      supported_parameters = {
                        reasoning_effort = true,
                        preserve_thinking = true,
                        temperature = true,
                        top_p = true,
                        top_k = true,
                        min_p = true,
                        presence_penalty = true,
                        repetition_penalty = true,
                      },
                      reasoning = {
                        mandatory = false,
                        default_enabled = true,
                        supported_efforts = {
                          "xhigh",
                          "medium",
                          "low",
                        },
                        default_effort = "xhigh",
                      },
                      default_parameters = {
                        preserve_thinking = true,
                        temperature = 1,
                        top_p = 0.95,
                        top_k = 20,
                        min_p = 0.0,
                        presence_penalty = 0.0,
                        repetition_penalty = 1.0,
                      },
                    },
                  },
                },
              },
              ["chat_template_kwargs.enable_thinking"] = {
                order = 2,
                mapping = "parameters",
                type = "boolean",
                optional = true,
                desc = "Включение рассуждений в vllm",
                enabled = function(self)
                  local choices = model_choices(self)
                  return (choices and choices.can_reason) or false
                end,
                ---@param self CodeCompanion.HTTPAdapter
                ---@return boolean
                default = function(self)
                  local choices = model_choices(self)
                  return (choices and choices.reasoning and choices.reasoning.default_enabled) or false
                end,
              },
              ["reasoning_effort"] = {
                order = 3,
                mapping = "parameters",
                type = "string",
                optional = true,
                ---@param self CodeCompanion.HTTPAdapter
                ---@return string
                default = function(self)
                  local choices = model_choices(self)
                  return (choices and choices.reasoning and choices.reasoning.default_effort) or "medium"
                end,
                enabled = function(self)
                  return model_supports(self, "reasoning_effort")
                end,
                desc = "Constrains effort on reasoning for reasoning models. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response. Not all efforts are supported by every model.",
                ---@param self CodeCompanion.HTTPAdapter
                ---@return string[]
                choices = function(self)
                  local choices = model_choices(self)
                  if choices and choices.reasoning and choices.reasoning.supported_efforts then
                    return choices.reasoning.supported_efforts
                  end
                  return { "xhigh", "high", "medium", "low", "minimal", "none" }
                end,
              },
              ["metadata.trace_user_id"] = {
                order = 4,
                mapping = "parameters",
                type = "string",
                desc = "ID пользователя для langfuse",
                default = "IANovikov@lanit.ru",
              },
            }

            local original_form_messages = adapter.handlers.form_messages
            adapter.handlers.form_messages = function(self, messages)
              messages = adapter_utils.merge_system_messages(messages)
              return original_form_messages(self, messages)
            end
            adapter.handlers.parse_message_meta = function(self, data)
              data = parse_reasoning(data)
              return data
            end
            return adapter
          end,
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
