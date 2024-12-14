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
      -- FIX: This isn't working on the desktop, but works on the mac.
      -- Likely an issue with terminal processing and not neovim.
      { "<C-S-h>", cmd("wincmd H"), desc = "Move window left" },
      { "<C-S-j>", cmd("wincmd J"), desc = "Move window down" },
      { "<C-S-k>", cmd("wincmd K"), desc = "Move window up" },
      { "<C-S-l>", cmd("wincmd L"), desc = "Move window right" },

      -- Window resizing
      { "<C-Left>", cmd("vertical resize -2"), desc = "Decrease window width" },
      { "<C-Down>", cmd("resize -2"), desc = "Decrease window height" },
      { "<C-Up>", cmd("resize +2"), desc = "Increase window height" },
      { "<C-Right>", cmd("vertical resize +2"), desc = "Increase window width" },

      -- Window splitting
      { "<C-s>=", cmd("wincmd ="), desc = "Make splits equal size" },
      { "<C-s>h", cmd("aboveleft vsplit"), desc = "Split vertical (left)" },
      { "<C-s>j", cmd("belowright split"), desc = "Split horizontal (below)" },
      { "<C-s>k", cmd("aboveleft split"), desc = "Split horizontal (above)" },
      { "<C-s>l", cmd("belowright vsplit"), desc = "Split vertical (right)" },

      -- Buffer navigation
      { "<Tab>", cmd("bnext"), desc = "Buffer next" },
      { "<S-Tab>", cmd("bprevious"), desc = "Buffer previous" },

      -- Tab navigation
      { "<C-n>", cmd("tabnext"), desc = "Tab next" },
      { "<C-b>", cmd("tabprevious"), desc = "Tab previous" },

      -- Leader mappings
      { "<leader>b", group = "[b]uffer" },
      { "<leader>bi", "gg=G", desc = "[i]ndent" },

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

      { "<leader>z", group = "[z]en mode" },
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
