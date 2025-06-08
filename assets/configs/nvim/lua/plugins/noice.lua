local cmd = require("utils").cmd

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        fps = 60,
        render = "compact",
        stages = "slide",
        timeout = 3000,
      },
    },
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
  },
  keys = {
    { "<leader>tn", cmd("Noice dismiss"), desc = "[n]oice" },
  },
}
