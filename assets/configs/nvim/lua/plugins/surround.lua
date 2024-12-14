return {
  "kylechui/nvim-surround",
  opts = {
    keymaps = {
      -- s -> Same line surround | Enter operator pending mode
      -- ss -> Same line surround | Whole line
      -- S -> Multi line surround | Enter operator pending mode
      -- SS -> Multi line surround | Whole line
      normal = "<leader>s",
      normal_cur = "<leader>ss",
      normal_line = "<leader>S",
      normal_cur_line = "<leader>SS",
      visual = "<leader>s",
      visual_line = "<leader>S",
      delete = "<leader>sd",
      change = "<leader>sc",
      change_line = "<leader>Sc",
    },
  },
  keys = {
    { "<leader>s", mode = { "n", "v" } },
    { "<leader>S", mode = { "n", "v" } },
  },
}
