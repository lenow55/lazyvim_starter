return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        ---@class lspconfig.Config
        ruff = {
          settings = {},
        },
      },
    },
  },
}
