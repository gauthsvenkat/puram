local cmd = require("utils").cmd

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    preset = "helix",
    spec = {
      { "<Esc>", cmd("nohlsearch"), desc = "Disable search highlight" },

      -- Window navigation
      { "<C-h>", cmd("wincmd h"), mode = { "n", "t" }, desc = "Move to window left" },
      { "<C-j>", cmd("wincmd j"), mode = { "n", "t" }, desc = "Move to window down" },
      { "<C-k>", cmd("wincmd k"), mode = { "n", "t" }, desc = "Move to window up" },
      { "<C-l>", cmd("wincmd l"), mode = { "n", "t" }, desc = "Move to window right" },

      -- Window splitting
      { "<C-p>=", cmd("wincmd ="), desc = "Make splits equal size" },
      { "<C-p>h", cmd("aboveleft vsplit"), desc = "Split vertical (left)" },
      { "<C-p>j", cmd("belowright split"), desc = "Split horizontal (below)" },
      { "<C-p>k", cmd("aboveleft split"), desc = "Split horizontal (above)" },
      { "<C-p>l", cmd("belowright vsplit"), desc = "Split vertical (right)" },

      -- Buffer navigation
      { "<C-n>", cmd("bnext"), desc = "Buffer next" },
      { "<C-b>", cmd("bprevious"), desc = "Buffer previous" },

      -- Leader mappings
      -- bindings defined in ./snacks.lua
      { "<leader>t", group = "[t]oggle" },

      { "<leader>s", group = "[s]earch" },

      -- bindings defined in ./gitsigns.lua
      { "<leader>g", group = "[g]it" },

      -- bindings defined in ./lsp.lua
      { "<leader>l", group = "[l]sp" },

      { "<leader>x", group = "diagnosti[x]" },
      {
        "]x",
        function()
          vim.diagnostic.jump({ count = vim.v.count1, float = false })
        end,
        desc = "next diagnostic",
      },
      {
        "[x",
        function()
          vim.diagnostic.jump({ count = -vim.v.count1, float = false })
        end,
        desc = "prev diagnostic",
      },

      -- bindings defined in treesitter.lua
      { "gw", group = "s[w]ap next" },
      { "gW", group = "s[W]ap prev" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "buffer local keymaps",
    },
  },
}
