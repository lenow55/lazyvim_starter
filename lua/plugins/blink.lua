return {
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "enter",
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
  },
}
