if true then
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
            model = "local/google/gemma-4-31B-it",
          },
          gates = {
            judge = {
              enabled = true,
              adapter = {
                name = "local_landev",
                model = "local/google/gemma-4-31B-it",
              },
            },
          },
        },
        chat = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
          },
          tools = {
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
            model = "local/google/gemma-4-31B-it",
          },
        },
        cmd = {
          adapter = {
            name = "local_landev",
            model = "local/google/gemma-4-31B-it",
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
