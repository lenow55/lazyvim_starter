-- if true then
--   return {}
-- end

local parse_reasoning = function(data)
  local extra = data.extra
  if extra and extra.reasoning_content and extra.reasoning_content ~= "" then
    data.output.reasoning = data.output.reasoning or {}
    data.output.reasoning.content = extra.reasoning_content
  end
  if data.output.content == "" then
    data.output.content = nil
  end
  return data
end

local dks_url = "https://llm.dks.lanit.ru/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          dks_ultra = function()
            local adapter = require("codecompanion.adapters.http").resolve("openai", {})
            local adapter_utils = require("codecompanion.adapters.utils")
            adapter.url = dks_url
            adapter.env = {
              api_key = "DKS_API_KEY",
            }
            adapter.opts = {
              stream = true,
              tools = true,
              vision = true,
            }
            adapter.schema.model = {
              order = 1,
              mapping = "parameters",
              type = "enum",
              desc = "ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.",
              default = "MiniMax-M3",
              choices = {
                ["MiniMax-M3"] = {
                  formatted_name = "MiniMax-M3",
                  meta = { context_window = 200000 },
                  opts = {
                    can_reason = true,
                    has_vision = true,
                  },
                },
                ["DKS-Ultra"] = {
                  formatted_name = "MiniMax-M2.7",
                  meta = { context_window = 200000 },
                  opts = {
                    can_reason = true,
                    has_vision = false,
                  },
                },
              },
            }
            adapter.schema.reasoning_effort = nil
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
