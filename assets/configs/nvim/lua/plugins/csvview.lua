return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  opts = {
    view = { display_mode = "border" },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
    },
  },
  config = function(_, opts)
    local csvview = require("csvview")
    csvview.setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function(ev)
        csvview.enable(ev.buf)
      end,
    })
  end,
}
