return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  opts = function()
    local rm = require("render-markdown")
    Snacks.toggle({
      name = "render [m]arkdown",
      get = rm.get,
      set = rm.set,
    }):map("<leader>tm")

    return {}
  end,
  ft = "markdown",
}
