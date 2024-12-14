local cmd = require("utils").cmd

return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      cmd("Trouble diagnostics toggle focus=true win.position=bottom filter.buf=0"),
      desc = "toggle (current buffer)",
    },
    {
      "<leader>xs",
      cmd("Trouble symbols toggle focus=true"),
      desc = "[s]ymbols toggle",
    },
    {
      "<leader>xl",
      cmd("Trouble lsp toggle focus=false win.position=right"),
      desc = "[l]sp toggle",
    },
    {
      "<leader>xn",
      vim.diagnostic.goto_next,
      desc = "goto [n]ext diagnostic",
    },
    {
      "<leader>xp",
      vim.diagnostic.goto_prev,
      desc = "goto [p]rev diagnostic",
    },
  },
}
