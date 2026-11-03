---windows dap config
return {
  {
    "mfussenegger/nvim-dap",
    optional = false,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      -- stylua: ignore
      keys = {
        { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
        { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
      },
      config = function()
        require("dap-python").setup(
          "C:/Users/IANovikov/AppData/Local/nvim-data/mason/packages/debugpy/venv/Scripts/python"
        )
      end,
    },
  },
  -- Don't mess up DAP adapters provided by nvim-dap-python
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = false,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
}
