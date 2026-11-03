if vim.g.lazyvim_codecompanion ~= true then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      adapters = {
        http = {
          gemini = function()
            return require("codecompanion.adapters.http").extend("gemini", {})
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
            model = "local/Qwen/Qwen3.8-27B-FP8",
          },
          gates = {
            judge = {
              enabled = true,
              adapter = {
                name = "local_landev",
                model = "local/Qwen/Qwen3.8-27B-FP8",
              },
            },
          },
        },
        chat = {
          adapter = {
            name = "local_landev",
            model = "local/Qwen/Qwen3.8-27B-FP8",
          },
          tools = {
            -- groups = {
            --   ["autoAgent"] = {
            --     description = "Agent - Can run code, edit code and modify files on your behalf",
            --     system_prompt = function(group, ctx)
            --       return string.format("")
            --     end,
            --     tools = {
            --       "ask_questions",
            --       "agent_skills",
            --       "auto_tools",
            --     },
            --     opts = {
            --       collapse_tools = true,
            --       ignore_system_prompt = true,
            --       ignore_tool_system_prompt = true,
            --     },
            --   },
            -- },
            ["delete_file"] = {
              opts = {
                judge = true,
              },
            },
            ["run_command"] = {
              opts = {
                judge = true,
              },
            },
            ["ask_questions"] = {
              visible = true,
            },
            opts = {
              system_prompt = {
                enabled = true,
              },
            },
          },
        },
        inline = {
          adapter = {
            name = "local_landev",
            model = "local/Qwen/Qwen3.8-27B-FP8",
          },
        },
        cmd = {
          adapter = {
            name = "local_landev",
            model = "local/Qwen/Qwen3.8-27B-FP8",
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
