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
        automcp = {
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
              list_tool_groups = {
                require_approval_before = false,
              },
              enable_tool_group = {
                require_approval_before = true,
              },
              disable_tool_group = {
                require_approval_before = false,
              },
            },
          },
        },
      },
    },
  },
}
