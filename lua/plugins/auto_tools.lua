if true then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      {
        "lenow55/codecompanion-mcp-manager",
      },
    },
    opts = {
      extensions = {
        auto_tools = {
          opts = {
            collapse_tools = true,
            no_approval_for = {
              "git",
              "agent_skills",
              "codebase_memory_mcp",
              "github",
              "neovim",
              "tavily",
              "fetch",
              "context7",
            },
            tool_opts = {
              list_tools = {
                require_approval_before = false,
              },
              enable_tool = {
                require_approval_before = true,
              },
              disable_tool = {
                require_approval_before = false,
              },
            },
          },
        },
      },
    },
  },
}
