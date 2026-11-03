if vim.g.lazyvim_codecompanion ~= true then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        agentskills = {
          opts = {
            paths = {
              "~/.claude/skills/codebase-memory",
              "~/my-agent-skills", -- Single directory (non-recursive)
              { "~/.config/nvim/lazyvim_starter/skills/", recursive = true }, -- Recursive search
              { "~/.local/share/nvim/codecompanion/superpowers/skills", recursive = true }, -- Recursive search
              { "~/lanit_projects/landev/code-agent-skills", recursive = true }, -- Recursive search
            },
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "lenow55/codecompanion-agentskills.nvim",
    },
  },
}
