return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local configs = require("nvim-treesitter.configs")
    local install = require("nvim-treesitter.install")

    install.ensure_installed = {
      "c", "lua", "vim", "vimdoc", "css", "vue",
      "php", "asm", "typescript", "javascript", "html"
    }

    configs.setup({
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,

}
