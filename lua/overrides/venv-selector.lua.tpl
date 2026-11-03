return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      settings = {
        search = { ---прописываем здесь пути, по которым надо искать
          miniconda_base = {
            command = "$FD /python$ /home/lenow/miniconda3/bin/ --no-ignore-vcs --full-path --color never",
            type = "anaconda",
          },
          miniconda_envs = {
            command = "$FD 'bin/python$' /home/lenow/miniconda3/envs --no-ignore-vcs --full-path",
            type = "anaconda",
          },
        },
      },
    },
  },
}

