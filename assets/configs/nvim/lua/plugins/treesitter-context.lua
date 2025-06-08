return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = function()
    local tsc = require("treesitter-context")
    Snacks.toggle({
      name = "treesitter [c]ontext",
      get = tsc.enabled,
      set = function(enable)
        if enable then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map("<leader>tc")

    return { max_lines = 3 }
  end,
}
