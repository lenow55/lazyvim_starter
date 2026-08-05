if true then
  return {}
end

return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
    opts = {
      log = {
        -- level = vim.log.levels.TRACE,
        -- to_file = true,
        -- file_path = "/home/lenow/.local/state/nvim/mcphub.log",
      },
      use_bundled_binary = true, -- Use local `mcp-hub` binary
      auto_approve = function(params)
        -- Respect CodeCompanion's auto tool mode when enabled
        if vim.g.codecompanion_auto_tool_mode == true then
          return true -- Auto approve when CodeCompanion auto-tool mode is on
        end

        -- Auto-approve safe file operations in current project
        if params.tool_name == "read_file" then
          local path = params.arguments.path or ""
          if path:match("^" .. vim.fn.getcwd()) then
            return true -- Auto approve
          end
        end

        -- Check if tool is configured for auto-approval in servers.json
        if params.is_auto_approved_in_server then
          return true -- Respect servers.json configuration
        end

        return false -- Show confirmation prompt
      end,
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
