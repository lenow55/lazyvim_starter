-- Общие хелперы для кастомных HTTP-адаптеров codecompanion.nvim
-- Лежит вне lua/plugins/, т.к. lazy.nvim интерпретирует каждый файл
-- в lua/plugins/ как spec (модуль обязан возвращать список спеков плагинов).
local M = {}

---@param args table Данные сообщения от HTTP-адаптера
---@return table
function M.parse_meta(args)
  local extra = args.data and args.data.extra
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

---@param self CodeCompanion.HTTPAdapter
---@param args { data: string|table, tools?: table }
---@return table|nil [status: string, output: table]
function M.parse_chat(self, args)
  local adapter_utils = require("codecompanion.adapters.utils")
  local data = args.data
  local tools = args.tools
  if not data or data == "" then
    return nil
  end

  -- Handle both streamed data and structured response
  local data_mod = type(data) == "table" and data.body or adapter_utils.clean_streamed_data(data)
  local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })
  if not ok then
    return nil
  end

  -- Handle non-streamed response
  if not self.opts.stream then
    -- Reasoning
    local reasoning = {}
    if json.output then
      for _, item in ipairs(json.output) do
        if item.type == "reasoning" then
          reasoning.id = item.id
          reasoning.encrypted_content = item.encrypted_content
          for _, block in ipairs(item.summary) do
            if block.type == "summary_text" then
              reasoning.content = reasoning.content and (reasoning.content .. "\n\n" .. block.text) or block.text
            end
          end
        end
      end
    end

    -- Tools
    if json.output and tools then
      local index = 1
      vim
        .iter(json.output)
        :filter(function(item)
          return item.type == "function_call"
        end)
        :each(function(tool)
          table.insert(tools, {
            _index = index,
            id = tool.id,
            call_id = tool.call_id,
            type = "function",
            ["function"] = {
              name = tool.name,
              arguments = tool.arguments or "",
            },
          })
          index = index + 1
        end)
    end

    -- Compaction: only keep the latest item
    local compaction = nil
    if json.output then
      for _, item in ipairs(json.output) do
        if item.type == "compaction" then
          compaction = item
        end
      end
    end

    local content = nil
    if json.output then
      for _, item in ipairs(json.output) do
        if item.type == "message" and item.content then
          for _, block in ipairs(item.content) do
            if block.type == "output_text" then
              content = (content or "") .. block.text
            end
          end
        end
      end
    end

    return {
      status = "success",
      output = {
        content = content,
        meta = {
          compaction = compaction,
          response_id = json.id,
        },
        reasoning = reasoning,
        role = self.roles.llm,
      },
    }
  end

  if json.type == "response.created" then
    response_id = json.response.id
  end

  local output = {}
  if json.type == "response.reasoning_summary_text.delta" then
    output = {
      role = self.roles.llm,
      reasoning = { content = json.delta or "" },
      meta = { response_id = response_id },
    }
  elseif json.type == "response.reasoning_text.delta" then
    output = {
      role = self.roles.llm,
      reasoning = { content = json.delta or "" },
      meta = { response_id = response_id },
    }
  elseif json.type == "response.output_text.delta" then
    output = {
      role = self.roles.llm,
      content = json.delta or "",
      meta = { response_id = response_id },
    }
  elseif json.type == "response.output_item.added" and json.item and json.item.type == "compaction" then
    output = {
      meta = {
        compaction = json.item,
        response_id = response_id,
      },
      role = self.roles.llm,
    }
  elseif json.type == "response.completed" then
    if json.response and json.response.output then
      local reasoning = {}
      vim
        .iter(json.response.output)
        :filter(function(reasoning_output)
          return reasoning_output.type == "reasoning"
        end)
        :each(function(reasoning_output)
          reasoning.id = reasoning_output.id
          reasoning.encrypted_content = reasoning_output.encrypted_content
        end)

      vim
        .iter(json.response.output)
        :filter(function(item)
          return item.type == "function_call" and item.status == "completed"
        end)
        :each(function(tool)
          if tools then
            table.insert(tools, {
              id = tool.id,
              call_id = tool.call_id,
              type = "function",
              ["function"] = {
                name = tool.name,
                arguments = tool.arguments or "",
              },
            })
          end
        end)

      -- Compaction: only keep the latest item
      local compaction = nil
      for _, item in ipairs(json.response.output) do
        if item.type == "compaction" then
          compaction = item
        end
      end

      output = {
        meta = {
          compaction = compaction,
          response_id = response_id,
        },
        reasoning = reasoning,
        role = self.roles.llm,
      }
    end
  end

  if vim.tbl_count(output) == 0 then
    return nil
  end

  return {
    status = "success",
    output = output,
  }
end

---Навешивает на openai-адаптер общие обёртки:
---* merge system-сообщений в form_messages
---* парсинг reasoning в parse_message_meta
---@param adapter CodeCompanion.HTTPAdapter
function M.apply_reasoning_sysmerge_handler(adapter)
  -- ленивый require: на момент загрузки спеков сам codecompanion.nvim ещё не загружен
  local adapter_utils = require("codecompanion.adapters.utils")
  -- local original_form_messages = adapter.handlers.form_messages
  adapter.handlers.form_messages = function(self, messages)
    messages = adapter_utils.merge_system_messages(messages)
    return original_form_messages(self, messages)
  end
  adapter.handlers.parse_meta = function(self, args)
    return M.parse_reasoning(args)
  end
end

---@param adapter CodeCompanion.HTTPAdapter
function M.apply_session_handler(adapter)
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
end

---@param adapter CodeCompanion.HTTPAdapter
---@return table|nil
function M.model_choices(adapter)
  local model = adapter.schema.model.choices[adapter.schema.model.default]
  return model and model.opts or nil
end

---@param adapter CodeCompanion.HTTPAdapter
---@param parameter string
---@return boolean
function M.model_supports(adapter, parameter)
  local model = adapter.schema.model.choices[adapter.schema.model.default]
  if not model then
    return false
  end
  return model.opts.supported_parameters[parameter] or false
end

M.metadata_uid = {
  order = 30,
  mapping = "parameters",
  type = "string",
  desc = "ID пользователя для langfuse",
  default = "IANovikov@lanit.ru",
}

M.common_schema = {
  ["reasoning_effort"] = {
    order = 9,
    mapping = "parameters",
    type = "string",
    optional = true,
    ---@param self CodeCompanion.HTTPAdapter
    ---@return string
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.reasoning and choices.reasoning.default_effort) or "medium"
    end,
    enabled = function(self)
      return M.model_supports(self, "reasoning_effort")
    end,
    desc = "Constrains effort on reasoning for reasoning models. Reducing reasoning effort can result in faster responses and fewer tokens used on reasoning in a response. Not all efforts are supported by every model.",
    ---@param self CodeCompanion.HTTPAdapter
    ---@return string[]
    choices = function(self)
      local choices = M.model_choices(self)
      if choices and choices.reasoning and choices.reasoning.supported_efforts then
        return choices.reasoning.supported_efforts
      end
      return { "xhigh", "high", "medium", "low", "minimal", "none" }
    end,
  },
  temperature = {
    order = 10,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.temperature) or 1
    end,
    enabled = function(self)
      return M.model_supports(self, "temperature")
    end,
    desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
    validate = function(n)
      return n >= 0 and n <= 2, "Must be between 0 and 2"
    end,
  },
  top_p = {
    order = 11,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.top_p) or 1
    end,
    enabled = function(self)
      return M.model_supports(self, "top_p")
    end,
    desc = "An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.",
    validate = function(n)
      return n >= 0 and n <= 1, "Must be between 0 and 1"
    end,
  },
  top_k = {
    order = 12,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.top_k) or -1
    end,
    enabled = function(self)
      return M.model_supports(self, "top_k")
    end,
    desc = "Integer that controls the number of top tokens to consider. Set to -1 to consider all tokens",
    validate = function(n)
      return n >= -1, "Must be greater than or equal to -1"
    end,
  },
  min_p = {
    order = 13,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.min_p) or 0
    end,
    enabled = function(self)
      return M.model_supports(self, "min_p")
    end,
    desc = "Float that represents the minimum probability for a token to be considered, relative to the probability of the most likely token",
    validate = function(n)
      return n >= 0 and n <= 1, "Must be between 0 and 1"
    end,
  },
  stop = {
    order = 14,
    mapping = "parameters",
    type = "list",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.stop) or nil
    end,
    enabled = function(self)
      return M.model_supports(self, "stop")
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
    order = 15,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.presence_penalty) or 0
    end,
    enabled = function(self)
      return M.model_supports(self, "presence_penalty")
    end,
    desc = "Float that penalizes new tokens based on whether they appear in the generated text so far. Values > 0 encourage the model to use new tokens, while values < 0 encourage the model to repeat tokens",
    validate = function(n)
      return n >= -2 and n <= 2, "Must be between -2 and 2"
    end,
  },
  frequency_penalty = {
    order = 16,
    mapping = "parameters",
    type = "number",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.frequency_penalty) or 0
    end,
    enabled = function(self)
      return M.model_supports(self, "frequency_penalty")
    end,
    desc = "Float that penalizes new tokens based on their frequency in the generated text so far. Values > 0 encourage the model to use new tokens, while values < 0 encourage the model to repeat tokens",
    validate = function(n)
      return n >= -2 and n <= 2, "Must be between -2 and 2"
    end,
  },
  logit_bias = {
    order = 17,
    mapping = "parameters",
    type = "map",
    optional = true,
    default = function(self)
      local choices = M.model_choices(self)
      return (choices and choices.default_parameters and choices.default_parameters.frequency_penalty) or nil
    end,
    enabled = function(self)
      return M.model_supports(self, "logit_bias")
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
}

return M
