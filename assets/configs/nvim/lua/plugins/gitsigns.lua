local cmd = require("utils").cmd

return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>tb", cmd("Gitsigns toggle_current_line_blame"), desc = "[b]lame" },
      { "<leader>td", cmd("Gitsigns toggle_deleted"), desc = "[d]eleted" },
      { "<leader>gr", cmd("Gitsigns reset_hunk"), desc = "[r]eset hunk" },
      { "<leader>gR", cmd("Gitsigns reset_buffer"), desc = "[R]eset buffer" },
      { "<leader>gs", cmd("Gitsigns stage_hunk"), desc = "(un)[s]tage hunk" },
      { "]h", cmd("Gitsigns next_hunk"), desc = "next [h]unk" },
      { "[h", cmd("Gitsigns prev_hunk"), desc = "prev [h]unk" },
    },
  },
}
