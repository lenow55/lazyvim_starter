if true then
  return {}
end

return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin для винды не работает
    opts = {
      log = {
        -- level = vim.log.levels.TRACE,
        to_file = true,
        file_path = "/home/lenow/.local/state/nvim/mcphub.log",
      },
      use_bundled_binary = true, -- Use local `mcp-hub` binary
    },
  },
}
