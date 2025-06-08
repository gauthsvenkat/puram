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
      ["<C-l>"] = { "actions.select", opts = { vertical = true } },
      ["<C-j>"] = { "actions.select", opts = { horizontal = true } },
    },
  },
  keys = {
    { "<Bs>", cmd("Oil --float"), desc = "oil" },
  },
}
