if vim.g.lazyvim_python_lsp ~= "pyrefly" then
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
          enabled = true,
        },
      },
    },
  },
}
