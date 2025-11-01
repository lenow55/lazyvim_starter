if true then
  return {}
end

---Output the data from the API ready for insertion into the chat buffer
---@param self CodeCompanion.HTTPAdapter
---@param data table The streamed JSON data from the API, also formatted by the format_data handler
---@param tools? table The table to write any tool output to
---@return { status: string, output: { role: string, content: string, reasoning: string? } } | nil
local reasoning_chat_output = function(self, data, tools)
  if not data or data == "" then
    return nil
  end
  local utils = require("codecompanion.utils.adapters")

  -- Handle both streamed data and structured response
  local data_mod = type(data) == "table" and data.body or utils.clean_streamed_data(data)
  local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

  if not ok or not json.choices or #json.choices == 0 then
    return nil
  end

  -- Process tool calls from all choices
  if self.opts.tools and tools then
    for _, choice in ipairs(json.choices) do
      local delta = self.opts.stream and choice.delta or choice.message

      if delta and delta.tool_calls and #delta.tool_calls > 0 then
        for i, tool in ipairs(delta.tool_calls) do
          local tool_index = tool.index and tonumber(tool.index) or i

          -- Some endpoints like Gemini do not set this (why?!)
          local id = tool.id
          if not id or id == "" then
            id = string.format("call_%s_%s", json.created, i)
          end

          if self.opts.stream then
            local found = false
            for _, existing_tool in ipairs(tools) do
              if existing_tool._index == tool_index then
                -- Append to arguments if this is a continuation of a stream
                if tool["function"] and tool["function"]["arguments"] then
                  existing_tool["function"]["arguments"] = (existing_tool["function"]["arguments"] or "")
                    .. tool["function"]["arguments"]
                end
                found = true
                break
              end
            end

            if not found then
              table.insert(tools, {
                _index = tool_index,
                id = id,
                type = tool.type,
                ["function"] = {
                  name = tool["function"]["name"],
                  arguments = tool["function"]["arguments"] or "",
                },
              })
            end
          else
            table.insert(tools, {
              _index = i,
              id = id,
              type = tool.type,
              ["function"] = {
                name = tool["function"]["name"],
                arguments = tool["function"]["arguments"],
              },
            })
          end
        end
      end
    end
  end

  -- Process message content from the first choice
  local choice = json.choices[1]
  local delta = self.opts.stream and choice.delta or choice.message

  if not delta then
    return nil
  end

  local output = {
    role = delta.role,
  }

  -- Handle reasoning content if present
  if delta.reasoning_content then
    output.reasoning = {
      content = delta.reasoning_content,
    }
  else
    output.content = delta.content
  end

  return {
    status = "success",
    output = output,
  }
end


return {
  -- {
  --   "Davidyz/VectorCode",
  --   -- version = "*", -- optional, depending on whether you're on nightly or release
  --   branch = "cli/chroma_1.0.x",
  --   build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     async_backend = "lsp", -- or "lsp"
  --     async_opts = {
  --       n_query = 2,
  --       notify = true,
  --     },
  --     -- exclude_this = true,
  --     n_query = 2,
  --     notify = true,
  --     timeout_ms = 5000,
  --     on_setup = {
  --       update = false, -- set to true to enable update when `setup` is called.
  --       lsp = false,
  --     },
  --   },
  -- },
  -- {
  --   "neovim/nvim-lspconfig",
  --   ---@class PluginLspOpts
  --   opts = {
  --     ---@type lspconfig.options
  --     servers = {
  --       vectorcode_server = {
  --         cmd_env = { VECTORCODE_LOG_LEVEL = "DEBUG" },
  --       },
  --     },
  --   },
  -- },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "here api key",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            schema = {
              model = {
                default = "qwen/qwen3-30b-a3b:free",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.8,
                desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                validate = function(n)
                  return n >= 0 and n <= 2, "Must be between 0 and 2"
                end,
              },
              max_completion_tokens = {
                order = 3,
                mapping = "parameters",
                type = "integer",
                optional = true,
                default = nil,
                desc = "An upper bound for the number of tokens that can be generated for a completion.",
                validate = function(n)
                  return n > 0, "Must be greater than 0"
                end,
              },
              stop = {
                order = 4,
                mapping = "parameters",
                type = "string",
                optional = true,
                default = nil,
                desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                validate = function(s)
                  return s:len() > 0, "Cannot be an empty string"
                end,
              },
              -- работает хреново, так как нормально в дебаге не отображается
              chat_template_kwargs = {
                order = 5,
                mapping = "parameters",
                type = "map",
                optional = true,
                -- default = { ["enable_thinking"] = false },
                default = nil,
                desc = "Extra body params for vllm",
                subtype_key = {
                  type = "string",
                },
                subtype = {
                  type = "boolean",
                },
                validate = function(s)
                  return true, "OK"
                end,
              },
            },
            opts = {
              stream = true,
              can_reason = true,
            },
            handlers = {
              chat_output = reasoning_chat_output,
            },
          })
        end,
        landev_openai = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://gpt-api.lanit.dev/balancer",
              api_key = "here api key",
              chat_url = "/v1/chat/completions",
              models_endpoint = "/v1/models",
            },
            raw = {
              "--header",
              "langfuse_trace_user_id: username",
              "--header",
              "langfuse_session_id: session-uuid",
            },
            schema = {
              model = {
                default = "Qwen/Qwen2.5-72B-Instruct-GPTQ-Int8",
              },
              temperature = {
                order = 2,
                mapping = "parameters",
                type = "number",
                optional = true,
                default = 0.8,
                desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                validate = function(n)
                  return n >= 0 and n <= 2, "Must be between 0 and 2"
                end,
              },
              max_completion_tokens = {
                order = 3,
                mapping = "parameters",
                type = "integer",
                optional = true,
                default = nil,
                desc = "An upper bound for the number of tokens that can be generated for a completion.",
                validate = function(n)
                  return n > 0, "Must be greater than 0"
                end,
              },
              stop = {
                order = 4,
                mapping = "parameters",
                type = "string",
                optional = true,
                default = nil,
                desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                validate = function(s)
                  return s:len() > 0, "Cannot be an empty string"
                end,
              },
            },
            handlers = {
              chat_output = reasoning_chat_output,
            },
            opts = {
              stream = true,
              can_reason = true,
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "my_openai",
          keymaps = {
            regenerate = {
              modes = {
                n = "<leader>Cr",
              },
              index = 3,
              callback = "keymaps.regenerate",
              description = "Regenerate the last response",
            },
            clear = {
              modes = {
                n = "<leader>Cx",
              },
              index = 6,
              callback = "keymaps.clear",
              description = "Clear Chat",
            },
            codeblock = {
              modes = {
                n = "<leader>Cc",
              },
              index = 7,
              callback = "keymaps.codeblock",
              description = "Insert Codeblock",
            },
            yank_code = {
              modes = {
                n = "<leader>Cy",
              },
              index = 8,
              callback = "keymaps.yank_code",
              description = "Yank Code",
            },
            debug = {
              modes = {
                n = "<leader>Cd",
              },
              index = 16,
              callback = "keymaps.debug",
              description = "View debug info",
            },
          },
        },
        inline = {
          adapter = "my_openai",
        },
        cmd = {
          adapter = "my_openai",
        },
      },
      opts = {
        language = "Russian",
        log_level = "TRACE",
      },
      extensions = {
        -- vectorcode = {
        --   opts = {
        --     add_tool = true,
        --     add_slash_command = true,
        --     -- tool_opts = {},
        --   },
        -- },
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
      },
      display = {
        chat = {
          icons = {
            chat_context = "📎️", -- You can also apply an icon to the fold
            chat_fold = "📎️",
          },
          fold_context = false,
          fold_reasoning = true,
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
