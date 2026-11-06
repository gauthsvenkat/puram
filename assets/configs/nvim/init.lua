require("config.options")
require("config.lazy")

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Highlight selection on yank",
  pattern = "*",
  callback = function()
    -- TODO: Switch to vim.hl.hl_op() once on Neovim 0.13.
    vim.hl.on_yank()
  end,
})
