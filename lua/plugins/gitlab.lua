if true then
  return {}
end

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        gitlab_ci_ls = {
          settings = {},
        },
      },
    },
  },
}
