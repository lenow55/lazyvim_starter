return {
  {
    "nvim-neotest/neotest",
    "nvim-neotest/nvim-nio",
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    ---@class neotest.CoreConfig
    opts = {
      log_level = vim.log.levels.DEBUG,
      adapters = {
        ---@class neotest-python.AdapterConfig
        ["neotest-python"] = {
          python = function(_)
            return require("venv-selector").python()
          end,
        },
      },
    },
  },
}
