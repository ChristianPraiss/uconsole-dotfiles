return {
  'm4xshen/autoclose.nvim',
  opts = {
    options = {
      disabled_filetypes = { "text" },
      disable_when_touch = true,
      touch_regex = "[%w(%[{]",
      pair_spaces = false,
      auto_indent = true,
      disable_command_mode = false,
    },
  },
}
