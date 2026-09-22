if true then
  return {}
end

return {
  {
    "georgeharker/sharedserver",
    build = "cargo install --path rust",
    lazy = false,
  },
  {
    "georgeharker/mcp-companion",
    dependencies = {
      "olimorris/codecompanion.nvim",
      "georgeharker/sharedserver",
    },
    build = "cd combiner && uv sync --frozen",
    opts = {
      combiner = {
        port = 9741,
        config = vim.fn.expand("~/.config/nvim/mcp/servers.json"),
      },
      log = { level = "info", notify = "error" },
      -- cc = {
      --   -- ключевое: НЕ авто-attach, модель сама подключит
      --   auto_native_tools = false,
      --   auto_http_tools = false,
      --   auto_acp_tools = false,
      --   -- убираем длинные inline-описания
      --   tool_system_prompts = false,
      -- },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        mcp_companion = {
          callback = "mcp_companion.cc",
          opts = {},
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
