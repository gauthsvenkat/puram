return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  main = "nvim-treesitter.configs",
  opts = {
    textobjects = {
      move = {
        enable = true,
        goto_next_start = {
          ["]a"] = { query = "@parameter.outer", desc = "Next [a]rgument start" },
          ["]c"] = { query = "@class.outer", desc = "Next [c]lass start" },
          ["]f"] = { query = "@function.outer", desc = "Next [f]unction start" },
          ["]i"] = { query = "@conditional.outer", desc = "Next [i]f start" },
          ["]l"] = { query = "@loop.outer", desc = "Next [l]oop start" },
          ["]o"] = { query = "@comment.outer", desc = "Next c[o]mment start" },
          ["]r"] = { query = "@return.outer", desc = "Next [r]eturn start" },
        },
        goto_next_end = {
          ["]A"] = { query = "@parameter.outer", desc = "Next [A]rgument end" },
          ["]C"] = { query = "@class.outer", desc = "Next [C]lass end" },
          ["]F"] = { query = "@function.outer", desc = "Next [F]unction end" },
          ["]I"] = { query = "@conditional.outer", desc = "Next [I]f end" },
          ["]L"] = { query = "@loop.outer", desc = "Next [L]oop end" },
          ["]O"] = { query = "@comment.outer", desc = "Next c[o]mment end" },
          ["]R"] = { query = "@return.outer", desc = "Next [R]eturn end" },
        },
        goto_previous_start = {
          ["[a"] = { query = "@parameter.outer", desc = "Previous [a]rgument start" },
          ["[c"] = { query = "@class.outer", desc = "Previous [c]lass start" },
          ["[f"] = { query = "@function.outer", desc = "Previous [f]unction start" },
          ["[i"] = { query = "@conditional.outer", desc = "Previous [i]f start" },
          ["[l"] = { query = "@loop.outer", desc = "Previous [l]oop start" },
          ["[o"] = { query = "@comment.outer", desc = "Previous c[o]mment start" },
          ["[r"] = { query = "@return.outer", desc = "Previous [r]eturn start" },
        },
        goto_previous_end = {
          ["[A"] = { query = "@parameter.outer", desc = "Previous [A]rgument end" },
          ["[C"] = { query = "@class.outer", desc = "Previous [C]lass end" },
          ["[F"] = { query = "@function.outer", desc = "Previous [F]unction end" },
          ["[I"] = { query = "@conditional.outer", desc = "Previous [I]f end" },
          ["[L"] = { query = "@loop.outer", desc = "Previous [L]oop end" },
          ["[O"] = { query = "@comment.outer", desc = "Previous c[o]mment end" },
          ["[R"] = { query = "@return.outer", desc = "Previous [R]eturn end" },
        },
      },
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["aa"] = { query = "@parameter.outer", desc = "[a]rgument" },
          ["ia"] = { query = "@parameter.inner", desc = "[a]rgument" },

          ["ac"] = { query = "@class.outer", desc = "[c]lass" },
          ["ic"] = { query = "@class.inner", desc = "[c]lass" },

          ["af"] = { query = "@function.outer", desc = "[f]unction" },
          ["if"] = { query = "@function.inner", desc = "[f]unction" },

          ["ai"] = { query = "@conditional.outer", desc = "[i]f" },
          ["ii"] = { query = "@conditional.inner", desc = "[i]f" },

          ["al"] = { query = "@loop.outer", desc = "[l]oop" },
          ["il"] = { query = "@loop.inner", desc = "[l]oop" },

          ["ao"] = { query = "@comment.outer", desc = "c[o]mment" },
          ["io"] = { query = "@comment.inner", desc = "c[o]mment" },

          ["ar"] = { query = "@return.outer", desc = "[r]eturn" },
          ["ir"] = { query = "@return.inner", desc = "[r]eturn" },
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["gwa"] = { query = "@parameter.inner", desc = "next [a]rgument" },
          ["gwc"] = { query = "@class.outer", desc = "next [c]lass" },
          ["gwf"] = { query = "@function.outer", desc = "next [f]unction" },
          ["gwi"] = { query = "@conditional.outer", desc = "next [i]f" },
        },
        swap_previous = {
          ["gWa"] = { query = "@parameter.inner", desc = "prev [a]rgument" },
          ["gWc"] = { query = "@class.outer", desc = "prev [c]lass" },
          ["gWf"] = { query = "@function.outer", desc = "prev [f]unction" },
          ["gWi"] = { query = "@conditional.outer", desc = "prev [i]f" },
        },
      },
    },
  },
}
