local cmd = require("utils").cmd

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    spec = {
      -- NOTE: this is not a recursive map since the
      -- <Esc> in rhs is not remapped
      { "<Esc>", "<Esc>" .. cmd("nohlsearch"), desc = "Disable search highlight" },

      -- Window navigation
      { "<C-h>", cmd("wincmd h"), mode = { "n", "t" }, desc = "Move to window left" },
      { "<C-j>", cmd("wincmd j"), mode = { "n", "t" }, desc = "Move to window down" },
      { "<C-k>", cmd("wincmd k"), mode = { "n", "t" }, desc = "Move to window up" },
      { "<C-l>", cmd("wincmd l"), mode = { "n", "t" }, desc = "Move to window right" },

      -- Window moving
      -- TODO: Inc / dec split sizes
      { "<C-s>h", cmd("wincmd H"), desc = "Move window left" },
      { "<C-s>j", cmd("wincmd J"), desc = "Move window down" },
      { "<C-s>k", cmd("wincmd K"), desc = "Move window up" },
      { "<C-s>l", cmd("wincmd L"), desc = "Move window right" },

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
      { "<leader>b", group = "[b]uffer" },
      { "<leader>bi", "gg=G", desc = "[i]ndent" },
      { "<leader>by", "ggyG", desc = "[y]ank" },

      { "<leader>c", group = "[c]omment", mode = { "n", "v" } },
      { "<leader>C", group = "[C]omment (block)", mode = { "n", "v" } },

      { "<leader>d", group = "[d]ebugger" },

      { "<leader>f", group = "[f]ind (telescope)" },

      { "<leader>g", group = "[g]it" },

      { "<leader>l", group = "[l]sp" },

      { "<leader>n", group = "[n]oice" },

      { "<leader>o", "o<Esc>k", desc = "Insert newline below" },
      { "<leader>O", "O<Esc>j", desc = "Insert newline above" },

      { "<leader>p", group = "[p]lugins" },
      { "<leader>pl", cmd("Lazy"), desc = "[l]azy" },

      { "<leader>s", group = "[s]urround", mode = { "n", "v" } },
      { "<leader>S", group = "[S]urround (line)", mode = { "n", "v" } },

      { "<leader>t", group = "[t]oggle" },
      {
        "<leader>td",
        function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end,
        desc = "[d]iagnostics",
      },

      { "<leader>w", group = "s[w]ap" },

      { "<leader>x", group = "trouble [x]0" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show()
      end,
      desc = "Buffer local keymaps (which-key)",
    },
  },
}
