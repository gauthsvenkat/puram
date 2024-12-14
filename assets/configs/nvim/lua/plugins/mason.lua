local cmd = require("utils").cmd

return {
  "williamboman/mason.nvim",
  lazy = false,
  opts = {},
  keys = {
    { "<leader>pm", cmd("Mason"), desc = "[m]ason" },
  },
}
