local cmd = require("utils").cmd

return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    { "<leader>ft", cmd("TodoTelescope keywords=TODO,FIX"), desc = "[t]odos" },
    { "<leader>fT", cmd("TodoTelescope keywords=TODO,FIX"), desc = "all [T]odos" },
  },
}
