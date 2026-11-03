if vim.g.lazyvim_python_lsp == "basedpyright" then
  return {}
end

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
                "basedpyright.dumpFileDebugInfo",
                "basedpyright.dumpCodeFlowGraph",
                "basedpyright.import",
                "basedpyright.writeBaseline",
              },
              workDoneProgress = true,
            }
          end,
          enabled = true,
        },
      },
    },
  },
}
