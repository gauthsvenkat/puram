return {
  "kylechui/nvim-surround",
  opts = {
    keymaps = {
      -- s -> Same line surround | Enter operator pending mode
      -- ss -> Same line surround | Whole line
      -- S -> Multi line surround | Enter operator pending mode
      -- SS -> Multi line surround | Whole line
      normal = "gs",
      normal_cur = "gss",
      normal_line = "gS",
      normal_cur_line = "gSS",
      visual = "gs",
      visual_line = "gS",
      delete = "ds",
      change = "cs",
    },
  },
  keys = {
    { "gs", mode = { "n", "v" } },
    { "gS", mode = { "n", "v" } },
    { "ds", mode = { "n", "v" } },
    { "cs", mode = { "n", "v" } },
  },
}
