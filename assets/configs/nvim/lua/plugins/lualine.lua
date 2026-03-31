return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    sections = {
      lualine_x = {},
      lualine_y = { "buffers" },
    },
  },
}
