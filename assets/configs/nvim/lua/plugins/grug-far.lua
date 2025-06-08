local cmd = require("utils").cmd

return {
  "MagicDuck/grug-far.nvim",
  opts = {},
  keys = { { "<leader>sR", cmd("GrugFar"), desc = "[R]eplace" } },
}
