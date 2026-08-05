if true then
  return {}
end

return {
  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "latex",
        "bibtex",
      },
    },
  },
  -- 2. Настраиваем маркап и inline-визуализацию формул
  {
    "OXY2DEV/markview.nvim",
    ft = { "markdown", "tex", "codecompanion" }, -- Включаем плагин для файлов Markdown и LaTeX
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        filetypes = { "markdown", "tex", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
}
