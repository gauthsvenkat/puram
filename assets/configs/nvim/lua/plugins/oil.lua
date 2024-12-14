local cmd = require("utils").cmd

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    win_options = {
      wrap = true,
    },
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      is_always_hidden = function(name, _)
        return name == ".."
      end,
    },
    keymaps = {
      ["h"] = "actions.parent",
      ["l"] = "actions.select",
      ["H"] = "actions.toggle_hidden",
      ["<CR>"] = "actions.close",
      ["<C-j>"] = { "actions.select", opts = { horizontal = true }, desc = "Open entry in horizontal window" },
      ["<C-l>"] = { "actions.select", opts = { vertical = true }, desc = "Open entry in vertical window" },
    },
  },
  keys = {
    { "<CR>", cmd("Oil --float"), desc = "Open Oil" },
  },
}
