return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      -- Parsers that should always be installed
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      -- Auto install missing parsers when entering a buffer
      auto_install = true,

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = false,
          node_incremental = ";",
          node_decremental = ",",
        },
      },
    },
  },
  {
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
            ["<leader>wa"] = { query = "@parameter.inner", desc = "next [a]rgument" },
            ["<leader>wc"] = { query = "@class.outer", desc = "next [c]lass" },
            ["<leader>wf"] = { query = "@function.outer", desc = "next [f]unction" },
            ["<leader>wi"] = { query = "@conditional.outer", desc = "next [i]f" },
            ["<leader>wl"] = { query = "@loop.outer", desc = "next [l]oop" },
          },
          swap_previous = {
            ["<leader>wA"] = { query = "@parameter.inner", desc = "previous [a]rgument" },
            ["<leader>wC"] = { query = "@class.outer", desc = "previous [c]lass" },
            ["<leader>wF"] = { query = "@function.outer", desc = "previous [f]unction" },
            ["<leader>wI"] = { query = "@conditional.outer", desc = "previous [i]f" },
            ["<leader>wL"] = { query = "@loop.outer", desc = "previous [l]oop" },
          },
        },
      },
    },
  },
}
