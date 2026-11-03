return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
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
        enabled = vim.g.lazyvim_python_lsp == "ty",
      },
    },
  },
}
