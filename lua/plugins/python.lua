return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        ---@class lspconfig.Config
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = "workspace",
                autoImportCompletions = true,
                exclude = {
                  ".venv/*",
                  "venv/*",
                  "/home/lenow/.cache/pypoetry/virtualenvs/",
                  "/home/lenow/miniconda3/envs/",
                },
                ignore = { "/home/lenow/.cache/pypoetry/virtualenvs/", "/home/lenow/miniconda3/envs/" },
                diagnosticSeverityOverrides = {
                  reportAny = "information",
                  reportUnknownMemberType = "warning",
                  reportUnknownArgumentType = "warning",
                  reportUnknownParameterType = "warning",
                  reportMissingParameterType = "warning",
                  reportUnknownVariableType = "warning",
                  reportDeprecated = "information",
                },
              },
              -- pyright = {
              --   disableOrganizeImports = false,
              -- },
            },
          },
          cmd = { "basedpyright-langserver", "--stdio" },
          cmd_env = { LC_ALL = "ru" },
          on_attach = function(client, _)
            client.server_capabilities.executeCommandProvider = {
              commands = {
                "basedpyright.createtypestub",
                "basedpyright.organizeimports",
                "basedpyright.unusedImport",
                "basedpyright.dumpCodeFlowGraph",
                "basedpyright.import",
                "basedpyright.writeBaseline",
              },
              workDoneProgress = true,
            }
          end,
        },
        ---@class lspconfig.Config
        ruff = {
          settings = {
            exclude = {
              "/home/lenow/.cache/pypoetry/virtualenvs/",
              "/home/lenow/miniconda3/envs/",
            },
          },
        },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    enabled = true,
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
        -- hooks = {},
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },
}
