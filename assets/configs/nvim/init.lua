-- NOTE: Make sure the following external dependencies are installed
-- - ripgrep (telescope)
-- - fd (telescope)
-- - nodejs (not sure but shit breaks if not there, copilot)
-- - python3 (lsp (mason))
-- - unzip (mason)
-- - gcc, make, cmake (a bunch of stuff)
require("config.options")
require("config.lazy")

-- Highlight on yank

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
