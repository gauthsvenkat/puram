return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { example = "doom" },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
  },
  keys = {
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "[d]elete",
    },
    {
      "<leader>bD",
      function()
        Snacks.bufdelete.other()
      end,
      desc = "[D]elete other",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse()
      end,
      desc = "[o]pen in browser",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "lazy[g]it",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "[l]og",
    },
    {
      "<leader>gL",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "file [L]og",
    },
  },
}
