local cmd = require("utils").cmd

return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>gb", cmd("Gitsigns toggle_current_line_blame"), desc = "toggle [b]lame" },
      { "<leader>gd", cmd("Gitsigns preview_hunk_inline"), desc = "[d]iff hunk inline" },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "lazy[g]it",
      },
      { "<leader>gr", cmd("Gitsigns reset_hunk"), desc = "[r]eset hunk" },
      { "<leader>gR", cmd("Gitsigns reset_buffer"), desc = "[R]eset buffer" },
      { "<leader>gs", cmd("Gitsigns stage_hunk"), desc = "(un)[s]tage hunk" },
      { "]h", cmd("Gitsigns nav_hunk next"), desc = "next [h]unk" },
      { "[h", cmd("Gitsigns nav_hunk prev"), desc = "prev [h]unk" },
    },
  },
}
