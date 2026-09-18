if true then
  return {}
end

local cc_utils = require("utils.codecompanion")

local dks_url = "https://llm.dks.lanit.ru/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          dks_ultra = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            adapter.url = dks_url
            adapter.env = {
              api_key = "DKS_API_KEY",
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
                default = "DKS-Vision",
                choices = {
                  ["DKS-Vision"] = {
                    formatted_name = "Qwen3.8-27B",
                    meta = { context_window = 262144 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = true,
                      supported_parameters = {
                        reasoning_effort = false,
                        preserve_thinking = true,
                        temperature = false,
                        top_p = false,
                        top_k = false,
                        min_p = false,
                        presence_penalty = false,
                        repetition_penalty = false,
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
                  ["GLM-5.3-Flash"] = {
                    formatted_name = "GLM-5.3-Flash",
                    meta = { context_window = 524288 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = true,
                      supported_parameters = {
                        reasoning_effort = true,
                        include_reasoning = true,
                        reasoning = true,
                        temperature = true,
                        top_p = true,
                        top_k = true,
                        min_p = true,
                        seed = true,
                        stop = true,
                        logprobs = true,
                        top_logprobs = true,
                        logit_bias = true,
                        presence_penalty = true,
                        repetition_penalty = true,
                        frequency_penalty = true,
                      },
                      reasoning = {
                        mandatory = true,
                        default_enabled = true,
                        supported_efforts = {
                          "max",
                          "high",
                          "low",
                        },
                        default_effort = "max",
                      },
                      default_parameters = {
                        temperature = 1,
                        top_p = 0.95,
                      },
                    },
                  },
                },
              },
            }, cc_utils.common_schema)
            cc_utils.apply_reasoning_sysmerge_handler(adapter)
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
