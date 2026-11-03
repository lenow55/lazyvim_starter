if vim.g.lazyvim_codecompanion ~= true then
  return {}
end

local cc_utils = require("utils.codecompanion")
local local_url = "http://localhost:8765/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          lenow = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai_legacy", {})
            adapter.url = local_url
            adapter.env = {
              api_key = "LENOW_APIKEY",
            }
            adapter.schema = vim.tbl_deep_extend("keep", {
              model = {
                order = 1,
                mapping = "parameters",
                type = "enum",
                desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
                default = "XHToken/Spark-X2.5-4B-FP8",
                choices = {
                  ["XHToken/Spark-X2.5-4B-FP8"] = {
                    formatted_name = "Spark-X2.5-4B",
                    meta = { context_window = 45000 },
                    opts = {
                      can_form_structured_outputs = true,
                      can_use_tools = true,
                      can_reason = true,
                      has_vision = false,
                      supported_parameters = {},
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
