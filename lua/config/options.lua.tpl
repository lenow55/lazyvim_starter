-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "basedpyright"
-- vim.g.lazyvim_python_lsp = "pyrefly"
-- vim.g.lazyvim_python_lsp = "ty"
vim.env["GEMINI_API_KEY"] = "***"
vim.env["LANDEV_API_KEY"] = "***"
vim.env["DKS_API_KEY"] = "***"


--- пример для работы с кастомным окружением питона в винде
vim.g.python3_host_prog = "C:\\Users\\IANovikov\\.conda\\envs\\nvim-env\\python.exe"

--- настройка для utf8-pwsh
local powershell_options = {
  shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
  shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
  shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
  shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
  shellquote = "",
  shellxquote = "",
}

for option, value in pairs(powershell_options) do
  vim.opt[option] = value
end

-- Включить CodeCompanion (раскомментируйте, чтобы включить).
-- vim.g.lazyvim_codecompanion = true

-- vim.g.lazyvim_gitlab_ci = true
-- vim.g.lazyvim_latex_inline = true
