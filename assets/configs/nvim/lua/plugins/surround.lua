return {
  "kylechui/nvim-surround",
  init = function()
    vim.g.nvim_surround_no_mappings = true
  end,
  keys = {
    { "gs", "<Plug>(nvim-surround-normal)", mode = "n" },
    { "gss", "<Plug>(nvim-surround-normal-cur)", mode = "n" },
    { "gS", "<Plug>(nvim-surround-normal-line)", mode = "n" },
    { "gSS", "<Plug>(nvim-surround-normal-cur-line)", mode = "n" },
    { "gs", "<Plug>(nvim-surround-visual)", mode = "x" },
    { "gS", "<Plug>(nvim-surround-visual-line)", mode = "x" },
    { "ds", "<Plug>(nvim-surround-delete)", mode = "n" },
    { "cs", "<Plug>(nvim-surround-change)", mode = "n" },
  },
}
