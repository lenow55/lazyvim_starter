if true then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        agentskills = {
          opts = {
            disable_demo_skill = true,
            paths = {
              -- "~/.claude/skills/codebase-memory",
              -- "~/my-agent-skills", -- Single directory (non-recursive)
              -- { "~/.config/nvim/skills", recursive = true }, -- Recursive search
              -- { "~/lanit_projects/landev/code-agent-skills", recursive = true }, -- Recursive search
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "cairijun/codecompanion-agentskills.nvim",
    },
  },
}
