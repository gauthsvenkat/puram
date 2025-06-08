return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
  },
  version = "*",
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      accept = { auto_brackets = { enabled = true } },
      menu = { draw = { treesitter = { "lsp" } } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = { enabled = false },
    },
    sources = {
      default = { "lsp", "path", "snippets", "lazydev", "buffer" },
      providers = { lazydev = { module = "lazydev.integrations.blink", score_offset = 100 } },
    },
    snippets = { preset = "luasnip" },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
