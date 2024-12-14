return {
  "numToStr/Comment.nvim",
  opts = {
    -- Operator pending mappings
    opleader = {
      line = "<leader>c",
      block = "<leader>C",
    },
    -- Line mappings
    toggler = {
      line = "<leader>cc",
      block = "<leader>CC",
    },
    mappings = {
      -- Comment.nvim has a couple of extra
      -- mappings which I don't care much about.
      extra = false,
    },
  },
  keys = {
    { "<leader>c", mode = { "n", "v" } },
    { "<leader>C", mode = { "n", "v" } },
  },
}
