local ensure_installed = require("utils").ensure_installed

return {
  "mfussenegger/nvim-lint",
  dependencies = { "williamboman/mason.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    ensure_installed({ "ruff", "mypy" })

    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "ruff", "mypy" },
    }

    -- Create an autocommand to run lint on certain events
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
  keys = {
    {
      "<leader>bl",
      function()
        require("lint").try_lint()
      end,
      desc = "[l]int",
    },
  },
}
