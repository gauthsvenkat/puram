-- TODO: Bunch more toggle options that probably need to be defined here
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { example = "doom" },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    indent = { enabled = true, chunk = { enabled = true } },
    words = { enabled = true },
  },
  keys = {
    {
      "<Del>",
      function()
        Snacks.lazygit()
      end,
      desc = "lazy[g]it",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse()
      end,
      desc = "[o]pen in browser",
    },
    {
      "<C-\\>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
    },
    {
      "<leader>tr",
      function()
        Snacks.toggle.words():toggle()
      end,
      desc = "[r]eferences",
    },
    {
      "<leader>ti",
      function()
        Snacks.toggle.indent():toggle()
      end,
      desc = "[i]ndent",
    },
    {
      "<leader>th",
      function()
        Snacks.toggle.inlay_hints():toggle()
      end,
      desc = "inlay [h]ints",
    },
    {
      "<leader>tx",
      function()
        Snacks.toggle.diagnostics({ name = "diagnostics" }):toggle()
      end,
      desc = "diagnosti[x]",
    },
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1, true)
      end,
      desc = "next reference",
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1, true)
      end,
      desc = "prev reference",
    },
  },
}
