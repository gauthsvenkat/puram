return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = { example = "doom" },
    explorer = { enabled = true, replace_netrw = false },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    indent = { enabled = true, chunk = { enabled = true } },
    notifier = { enabled = true },
    picker = { enabled = true },
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
    Snacks.toggle.dim():map("<leader>td")

    Snacks.toggle
      .new({
        id = "diagnostic_virtual_text",
        name = "[v]irtual text",
        get = function()
          return (vim.diagnostic.config().virtual_text or false) and true
        end,
        set = function(enable)
          if enable then
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
      "<leader><leader>",
      function()
        Snacks.picker.resume()
      end,
      desc = "resume last search",
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.files()
      end,
      desc = "[f]iles",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "[b]uffers",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "[q]uickfix",
    },
    {
      "<leader>sg",
      function()
        Snacks.picker.grep()
      end,
      desc = "live [g]rep",
    },
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "[h]elptags",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.pickers()
      end,
      desc = "[s]earch pickers",
    },
    {
      "<leader>sr",
      function()
        Snacks.picker.registers()
      end,
      desc = "[r]egisters",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "[c]ommand history",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "[m]arks",
    },
    {
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "[j]umps",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "[d]iagnostics",
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "[D]iagnostics (workspace)",
    },
    {
      "<leader>f",
      function()
        Snacks.picker.files()
      end,
      desc = "[f]iles",
    },
    {
      "<leader>b",
      function()
        Snacks.picker.buffers()
      end,
      desc = "[b]uffers",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "live grep",
    },
    {
      "]w",
      function()
        Snacks.words.jump(vim.v.count1, true)
      end,
      desc = "next [w]ord reference",
    },
    {
      "[w",
      function()
        Snacks.words.jump(-vim.v.count1, true)
      end,
      desc = "prev [w]ord reference",
    },
    {
      "<Del>",
      function()
        Snacks.lazygit()
      end,
      desc = "lazy[g]it",
    },
    {
      "<leader>c",
      function()
        Snacks.bufdelete.delete()
      end,
      desc = "[c]lose buffer",
    },
    {
      "<leader>C",
      function()
        Snacks.bufdelete.other()
      end,
      desc = "[C]lose other buffers",
    },
    {
      "<leader>e",
      function()
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:close()
        else
          Snacks.explorer.open({ focus = false })
        end
      end,
      desc = "[e]xplorer",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse()
      end,
      desc = "[o]pen in browser",
    },
    {
      "<leader>h",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "notification [h]istory",
    },
    {
      "<C-\\>",
      function()
        Snacks.terminal()
      end,
      mode = { "n", "t" },
    },
  },
}
