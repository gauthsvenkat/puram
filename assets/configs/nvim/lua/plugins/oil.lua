local cmd = require("utils").cmd

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    keymaps = {
      ["<Bs>"] = "actions.parent",
      ["q"] = "actions.close",
      ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
    },
  },
  keys = {
    { "<Bs>", cmd("Oil --float"), desc = "oil" },
  },
}
