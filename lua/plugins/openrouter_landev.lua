-- if true then
--   return {}
-- end

local landev_url = "https://dev02-lb.gpt.dks.lanit.ru/v1/chat/completions"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          openrouter_landev = function()
            local adapter = require("codecompanion.adapters.http").resolve("openrouter", {})
            local fetch_models = require("codecompanion.adapters.utils.models.fetch")
            local models_source = {
              name = "OpenRouter",
              url = "https://openrouter.ai/api/v1/models",
            }

            ---@param self CodeCompanion.HTTPAdapter
            ---@return table|nil
            local function model_choices(self)
              local cached_models = fetch_models.get(models_source, self)
              local prefixed = {}
              for id, choice in pairs(cached_models) do
                prefixed["openrouter/" .. id] = choice
              end
              local model = prefixed[self.schema.model.default]
              return model and model.opts or nil
            end

            ---@param self CodeCompanion.HTTPAdapter
            ---@param parameter string
            ---@return boolean
            local function model_supports(self, parameter)
              local cached_models = fetch_models.get(models_source, self)
              local prefixed = {}
              for id, choice in pairs(cached_models) do
                prefixed["openrouter/" .. id] = choice
              end
              local model = prefixed[self.schema.model.default]
              if not model then
                return false
              end

              return model.opts.supported_parameters[parameter] or false
            end

            adapter.url = landev_url
            adapter.env = {
              api_key = "LANDEV_API_KEY",
            }
            adapter.features = {
              text = true,
              tokens = true,
            }
            adapter.available_tools = {}
            ---@param self CodeCompanion.HTTPAdapter
            ---@param data table The request payload built by the chat buffer
            ---@return table|nil
            adapter.handlers.set_body = function(self, data)
              -- A user's session ID takes priority...
              if self.opts and self.opts.session_id then
                return { metadata = { session_id = self.opts.session_id } }
              end

              -- ...over one from the chat buffer
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
                default = "openrouter/anthropic/claude-sonnet-4",
                choices = function(self, opts)
                  local models = fetch_models.get(models_source, self, opts)
                  local prefixed = {}
                  for id, choice in pairs(models) do
                    prefixed["openrouter/" .. id] = choice
                  end
                  return prefixed
                end,
              },

              ["reasoning.effort"] = {
                order = 2,
                mapping = "parameters",
                type = "string",
                optional = true,
                ---@param self CodeCompanion.HTTPAdapter
                ---@return string
                default = function(self)
                  local choices = model_choices(self)
                  return (choices and choices.reasoning and choices.reasoning.default) or "medium"
                end,
                enabled = function(self)
                  return model_supports(self, "reasoning")
                end,
                desc = "Constrains effort on reasoning for reasoning models. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response. Not all efforts are supported by every model.",
                ---@param self CodeCompanion.HTTPAdapter
                ---@return string[]
                choices = function(self)
                  local choices = model_choices(self)
                  if choices and choices.reasoning and choices.reasoning.supported then
                    return choices.reasoning.supported
                  end
                  return { "xhigh", "high", "medium", "low", "minimal", "none" }
                end,
              },
              temperature = {
                order = 3,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 1,
                enabled = function(self)
                  return model_supports(self, "temperature")
                end,
                desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                validate = function(n)
                  return n >= 0 and n <= 2, "Must be between 0 and 2"
                end,
              },
              top_p = {
                order = 4,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 1,
                enabled = function(self)
                  return model_supports(self, "top_p")
                end,
                desc = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.",
                validate = function(n)
                  return n >= 0 and n <= 1, "Must be between 0 and 1"
                end,
              },
              top_k = {
                order = 5,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = -1,
                enabled = function(self)
                  return model_supports(self, "top_k")
                end,
                desc = "Integer that controls the number of top tokens to consider. Set to -1 to consider all tokens",
                validate = function(n)
                  return n >= -1, "Must be greater than or equal to -1"
                end,
              },
              min_p = {
                order = 6,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0,
                enabled = function(self)
                  return model_supports(self, "min_p")
                end,
                desc = "Float that represents the minimum probability for a token to be considered, relative to the probability of the most likely token",
                validate = function(n)
                  return n >= 0 and n <= 1, "Must be between 0 and 1"
                end,
              },
              stop = {
                order = 7,
                mapping = "parameters",
                type = "list",
                optional = true,
                default = nil,
                enabled = function(self)
                  return model_supports(self, "stop")
                end,
                subtype = {
                  type = "string",
                },
                desc = "Up to 4 sequences where the API will stop generating further tokens.",
                validate = function(l)
                  return #l >= 1 and #l <= 4, "Must have between 1 and 4 elements"
                end,
              },
              presence_penalty = {
                order = 8,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0,
                enabled = function(self)
                  return model_supports(self, "presence_penalty")
                end,
                desc = "Float that penalizes new tokens based on whether they appear in the generated text so far. Values > 0 encourage the model to use new tokens, while values < 0 encourage the model to repeat tokens",
                validate = function(n)
                  return n >= -2 and n <= 2, "Must be between -2 and 2"
                end,
              },
              frequency_penalty = {
                order = 9,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0,
                enabled = function(self)
                  return model_supports(self, "frequency_penalty")
                end,
                desc = "Float that penalizes new tokens based on their frequency in the generated text so far. Values > 0 encourage the model to use new tokens, while values < 0 encourage the model to repeat tokens",
                validate = function(n)
                  return n >= -2 and n <= 2, "Must be between -2 and 2"
                end,
              },
              logit_bias = {
                order = 10,
                mapping = "parameters",
                type = "map",
                optional = true,
                default = nil,
                enabled = function(self)
                  return model_supports(self, "logit_bias")
                end,
                desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
                subtype_key = {
                  type = "integer",
                },
                subtype = {
                  type = "integer",
                  validate = function(n)
                    return n >= -100 and n <= 100, "Must be between -100 and 100"
                  end,
                },
              },
              ["metadata.trace_user_id"] = {
                order = 21,
                mapping = "parameters",
                type = "string",
                desc = "ID пользователя для langfuse",
                default = "IANovikov@lanit.ru",
              },
            }
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
