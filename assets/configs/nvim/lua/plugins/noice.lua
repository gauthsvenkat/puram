local cmd = require("utils").cmd

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    presets = {
      long_message_to_split = true,
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
  },
  keys = {
    { "<leader>nn", cmd("Noice dismiss"), desc = "dismiss" },
    { "<leader>nm", cmd("Noice telescope"), desc = "[m]essages" },
  },
}
