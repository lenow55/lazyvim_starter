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
                ignore = {
                  ".venv/*",
                  "venv/*",
                  "typings/*",
                  "/home/lenow/.cache/pypoetry/virtualenvs/",
                  "/home/lenow/miniconda3/envs/",
                },
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
          enabled = true,
        },
        ---@class lspconfig.Config
        pyrefly = {
          settings = {
            python = {
              pyrefly = {
                displayTypeErrors = "force-on",
                analysis = {
                  diagnosticMode = "workspace",
                },
                project_excludes = {
                  "**/.venv/**",
                  "**/venv/**",
                  "/home/lenow/.cache/pypoetry/virtualenvs/**",
                  "/home/lenow/miniconda3/envs/**",
                },
              },
            },
          },
          enabled = false,
        },
        ---@class lspconfig.Config
        ty = {
          cmd = { "ty", "server" },
          filetypes = { "python" },
          settings = {
            ty = {
              configuration = {
                src = {
                  exclude = {
                    ".venv/**",
                    "venv/**",
                    "/home/lenow/.cache/pypoetry/virtualenvs/**",
                    "/home/lenow/miniconda3/envs/**",
                  },
                },
              },
            },
          },
          root_markers = { "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
          init_options = {
            logFile = "~/.local/state/nvim/ty.log",
            logLevel = "trace",
            diagnosticMode = "workspace",
            -- c workspace диагностикой не работает в neovim, так как
            -- он не поддерживает стримминг диагностики
          },
          enabled = false,
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
    branch = "main",
    enabled = true,
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
        -- hooks = {},
        search = {
          miniconda_base = {
            command = "$FD /python$ /home/lenow/miniconda3/bin/ --no-ignore-vcs --full-path --color never",
            type = "anaconda",
          },
          miniconda_envs = {
            command = "$FD 'bin/python$' /home/lenow/miniconda3/envs --no-ignore-vcs --full-path",
            type = "anaconda",
          },
        },
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },
}
