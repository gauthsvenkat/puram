local cmd = require("utils").cmd

return {
  "stevearc/aerial.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    layout = { default_direction = "right", placement = "edge" },
    show_guides = true,
  },
  keys = {
    { "<leader>a", cmd("AerialToggle!"), desc = "[a]erial" },
  },
}
