local cmd = require("utils").cmd

return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    { "<leader>tt", cmd("TodoTelescope keywords=TODO,FIX"), desc = "list [t]odos" },
    { "<leader>ta", cmd("TodoTelescope keywords=TODO,FIX"), desc = "list [a]ll todo comments" },
  },
}
