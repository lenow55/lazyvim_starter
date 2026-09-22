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
            individual_tools = { "subagent_*", "read_file" },
            deny_groups = { "agent", "mcp" },
            no_approval_for = {
              "git",
              "github",
              "neovim",
              "files",
              "tavily",
              "fetch",
              "context7",
              "agent_skills",
              "codebase_memory_mcp",
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
