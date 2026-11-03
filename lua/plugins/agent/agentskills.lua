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
            disable_demo_skill = true,
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
