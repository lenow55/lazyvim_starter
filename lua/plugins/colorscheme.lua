-- if true then
--   return {}
-- end
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
    -- version = "v4.8.0",
    -- commit = "30d7be361a7fbf187a881f17e574e9213d5108ea",
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
      end,
    },
  },
}
