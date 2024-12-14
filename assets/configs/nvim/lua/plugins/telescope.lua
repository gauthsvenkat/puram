local cmd = require("utils").cmd

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    },
  },
  opts = {
    defaults = {
      layout_strategy = "vertical",
      mappings = {
        i = {
          ["<esc>"] = require("telescope.actions").close,
          -- Mainly used for pickers while sort over files (like find_files
          -- and live_grep).
          ["<C-j>"] = require("telescope.actions").select_horizontal,
          ["<C-l>"] = require("telescope.actions").select_vertical,
          ["<C-x>"] = require("telescope.actions").delete_buffer,
        },
      },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
  keys = {
    { "<leader>fp", cmd("Telescope builtin"), desc = "Builtin [p]ickers" },
    { "<leader>ff", cmd("Telescope find_files"), desc = "[f]iles" },
    { "<leader>fF", cmd("Telescope find_files hidden=true"), desc = "hidden [F]iles" },
    { "<leader>fg", cmd("Telescope live_grep"), desc = "Live [g]rep" },
    { "<leader>fb", cmd("Telescope buffers"), desc = "[b]uffers" },
    { "<leader><leader>", cmd("Telescope buffers"), desc = "buffers" },
    { "<leader>fh", cmd("Telescope help_tags"), desc = "[h]elp tags" },
  },
}
