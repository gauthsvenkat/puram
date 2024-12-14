local ensure_installed = require("utils").ensure_installed

return {
  "stevearc/conform.nvim",
  dependencies = { "williamboman/mason.nvim" },
  event = { "BufWritePre" },
  -- TODO: Toggle format on save
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { --[[ "ruff_fix", ]]
        "ruff_format",
        "ruff_organize_imports",
      },
      rust = { "rustfmt" },
    },
  },
  config = function(_, opts)
    ensure_installed({ "stylua", "ruff", "rustfmt" })
    require("conform").setup(opts)
  end,
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>bf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "v" },
      desc = "[f]ormat",
    },
  },
}
