local function todos(keywords)
  return function()
    Snacks.picker.todo_comments({ keywords = keywords })
  end
end

return {
  "folke/todo-comments.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  opts = { signs = false },
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "next [t]odo comment",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "prev [t]odo comment",
    },
    { "<leader>sta", todos(), desc = "[a]ll" },
    { "<leader>stt", todos({ "TODO" }), desc = "[t]odo" },
    { "<leader>stf", todos({ "FIX", "FIXME", "BUG", "FIXIT", "ISSUE" }), desc = "[f]ix" },
    { "<leader>stn", todos({ "NOTE", "INFO" }), desc = "[n]ote" },
  },
}
