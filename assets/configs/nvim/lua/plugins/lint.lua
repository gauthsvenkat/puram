return {
  "mfussenegger/nvim-lint",
  dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- NOTE: Ensure linters are installed by adding them to mason.lua
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "ruff", "mypy" },
    }

    -- Create an autocommand to run lint on certain events
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
