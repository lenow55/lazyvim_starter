if true then
  return {}
end

local cc_utils = require("utils.codecompanion")
local landev_url = "https://dev02-lb.gpt.dks.lanit.ru/v1/chat/completions"
-- local landev_url = "http://litellm.dev02.svc.cluster.local:4000/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
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
            adapter.schema = vim.tbl_deep_extend("keep", {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
                default = "local/google/gemma-4-31B-it",
                choices = {
                  ["local/google/gemma-4-31B-it"] = {
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
                  ["local/Qwen/Qwen3.8-27B-FP8"] = {
                    formatted_name = "Qwen3.8-27B",
                    meta = { context_window = 200000 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = true,
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
              ["metadata.trace_user_id"] = cc_utils.metadata_uid,
            }, cc_utils.common_schema)
            cc_utils.apply_reasoning_sysmerge_handler(adapter)
            cc_utils.apply_session_handler(adapter)
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
