return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "alfaix/neotest-gtest",
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
        ["neotest-gtest"] = { setup = {} },
      },
    },
  },
}
