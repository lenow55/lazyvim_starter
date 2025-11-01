return {
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        -- your zen configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        ---@type table<string, boolean>
        toggles = {
          dim = true,
          git_signs = true,
          mini_diff_signs = false,
          -- diagnostics = false,
          -- inlay_hints = false,
        },
        show = {
          statusline = true, -- can only be shown when using the global statusline
          tabline = false,
        },
      },
    },
  },
}
