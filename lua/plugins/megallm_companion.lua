-- if true then
--   return {}
-- end

local cc_utils = require("utils.codecompanion")

local megallm_url = "http://megallm:8777/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          megallm = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            adapter.url = megallm_url
            adapter.env = {
              api_key = "EMPTY",
            }
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
            adapter.schema = vim.tbl_deep_extend("error", {
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
                  local choices = cc_utils.model_choices(self)
                  return (choices and choices.can_reason) or false
                end,
                ---@param self CodeCompanion.HTTPAdapter
                ---@return boolean
                default = function(self)
                  local choices = cc_utils.model_choices(self)
                  return (choices and choices.reasoning and choices.reasoning.default_enabled) or false
                end,
              },
              ["metadata.trace_user_id"] = {
                order = 3,
                mapping = "parameters",
                type = "string",
                desc = "ID пользователя для langfuse",
                default = "IANovikov@lanit.ru",
              },
            }, cc_utils.common_schema)
            cc_utils.apply_common_handlers(adapter)
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
