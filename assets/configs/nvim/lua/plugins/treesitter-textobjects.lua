return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
    })

    local select_to = require("nvim-treesitter-textobjects.select").select_textobject
    local move = require("nvim-treesitter-textobjects.move")
    local swap = require("nvim-treesitter-textobjects.swap")

    local objects = {
      { key = "a", query = "@parameter", desc = "[a]rgument" },
      { key = "c", query = "@class", desc = "[c]lass" },
      { key = "f", query = "@function", desc = "[f]unction" },
      { key = "i", query = "@conditional", desc = "[i]f" },
      { key = "l", query = "@loop", desc = "[l]oop" },
      { key = "o", query = "@comment", desc = "c[o]mment" },
      { key = "r", query = "@return", desc = "[r]eturn" },
    }

    for _, obj in ipairs(objects) do
      local k, q, d = obj.key, obj.query, obj.desc

      -- Select
      vim.keymap.set({ "x", "o" }, "a" .. k, function()
        select_to(q .. ".outer", "textobjects")
      end, { desc = d })

      vim.keymap.set({ "x", "o" }, "i" .. k, function()
        select_to(q .. ".inner", "textobjects")
      end, { desc = d })

      -- Move
      vim.keymap.set({ "n", "x", "o" }, "]" .. k, function()
        move.goto_next_start(q .. ".outer", "textobjects")
      end, { desc = "Next " .. d .. " start" })
      vim.keymap.set({ "n", "x", "o" }, "]" .. k:upper(), function()
        move.goto_next_end(q .. ".outer", "textobjects")
      end, { desc = "Next " .. d .. " end" })
      vim.keymap.set({ "n", "x", "o" }, "[" .. k, function()
        move.goto_previous_start(q .. ".outer", "textobjects")
      end, { desc = "Prev " .. d .. " start" })
      vim.keymap.set({ "n", "x", "o" }, "[" .. k:upper(), function()
        move.goto_previous_end(q .. ".outer", "textobjects")
      end, { desc = "Prev " .. d .. " end" })
    end

    -- Swap (subset of objects)
    local swap_objects = {
      { key = "a", query = "@parameter.inner", desc = "[a]rgument" },
      { key = "c", query = "@class.outer", desc = "[c]lass" },
      { key = "f", query = "@function.outer", desc = "[f]unction" },
      { key = "i", query = "@conditional.outer", desc = "[i]f" },
    }

    for _, obj in ipairs(swap_objects) do
      vim.keymap.set("n", "gw" .. obj.key, function()
        swap.swap_next(obj.query)
      end, { desc = "next " .. obj.desc })
      vim.keymap.set("n", "gW" .. obj.key, function()
        swap.swap_previous(obj.query)
      end, { desc = "prev " .. obj.desc })
    end
  end,
}
