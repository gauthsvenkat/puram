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
    toggle = { color = { disabled = "red" }, wk_desc = { enabled = "", disabled = "" } },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- start toggle keymaps
    Snacks.toggle.inlay_hints({ name = "inlay [h]ints" }):map("<leader>th")
    Snacks.toggle.diagnostics({ name = "diagnostic[x]" }):map("<leader>tx")
    Snacks.toggle.treesitter({ name = "[t]reesitter" }):map("<leader>tt")
    Snacks.toggle.indent():map("<leader>ti")
    Snacks.toggle.words():map("<leader>tr")

    Snacks.toggle
      .new({
        id = "diagnostic_virtual_text",
        name = "[v]irtual text",
        get = function()
          return (vim.diagnostic.config().virtual_text or false) and true
        end,
        set = function(enable)
          if enable then
            -- NOTE: Keep following and ../config/options.lua in sync.
            vim.diagnostic.config({ virtual_text = { source = "if_many", spacing = 2 } })
          else
            vim.diagnostic.config({ virtual_text = false })
          end
        end,
      })
      :map("<leader>tv")
    -- end toggle keymaps
  end,
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
