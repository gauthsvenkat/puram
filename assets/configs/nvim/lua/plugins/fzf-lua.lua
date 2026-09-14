local cmd = require("utils").cmd

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = { { "telescope" } },
  keys = {
    { "<leader><leader>", cmd("FzfLua resume"), desc = "resume last search" },
    { "<leader>sf", cmd("FzfLua files"), desc = "[f]iles" },
    { "<leader>sb", cmd("FzfLua buffers sort_mru=true sort_lastused=true"), desc = "[b]uffers" },
    { "<leader>sq", cmd("FzfLua quickfix"), desc = "[q]uickfix" },
    { "<leader>sg", cmd("FzfLua live_grep_native"), desc = "live [g]rep" },
    { "<leader>sh", cmd("FzfLua helptags"), desc = "[h]elptags" },
    { "<leader>ss", cmd("FzfLua builtin"), desc = "[s]earch builtins" },
    { "<leader>sr", cmd("FzfLua registers"), desc = "[r]egisters" },
    { "<leader>sc", cmd("FzfLua command_history"), desc = "[c]ommand history" },
    { "<leader>sm", cmd("FzfLua marks"), desc = "[m]arks" },
    { "<leader>sj", cmd("FzfLua jumps"), desc = "[j]umps" },
    { "<leader>sd", cmd("FzfLua diagnostics_document"), desc = "[d]iagnostics" },
    { "<leader>sD", cmd("FzfLua diagnostics_workspace"), desc = "[D]iagnostics (workspace)" },

    -- some fast shortcuts :-)
    { "<leader>f", cmd("FzfLua files"), desc = "[f]iles" },
    { "<leader>b", cmd("FzfLua buffers sort_mru=true sort_lastused=true"), desc = "[b]uffers" },
    { "<leader>/", cmd("FzfLua live_grep_native"), desc = "live grep" },
    { "<leader>:", cmd("FzfLua commands"), desc = "neovim commands" },
  },
  cmd = { "FzfLua" },
}
