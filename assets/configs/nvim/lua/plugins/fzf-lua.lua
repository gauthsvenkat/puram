local cmd = require("utils").cmd

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    { "telescope" },
    -- NOTE: Need the following line to inherit defaults
    actions = { files = { true } },
  },
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

    -- some fast shortcuts :-)
    { "<leader>f", cmd("FzfLua files"), desc = "[f]iles" },
    { "<leader>b", cmd("FzfLua buffers sort_mru=true sort_lastused=true"), desc = "[b]uffers" },
    { "<leader>/", cmd("FzfLua live_grep_native"), desc = "live grep" },
    { "<leader>:", cmd("FzfLua commands"), desc = "neovim commands" },

    -- NOTE: I think the following will also work for non LSP diagnostics. But keep an eye.
    { "gx", cmd("FzfLua lsp_document_diagnostics"), desc = "document diagnostics" },
    { "gX", cmd("FzfLua lsp_workspace_diagnostics"), desc = "workspace diagnostics" },
  },
  cmd = { "FzfLua" },
}
