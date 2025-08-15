return {
  "stevearc/conform.nvim",
  event = { "InsertEnter" },
  opts = function()
    -- commands to enable or disable autoformat
    vim.api.nvim_create_user_command("FormatDisable", function()
      vim.g.disable_autoformat = true
    end, { desc = "Disable autoformat-on-save" })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.g.disable_autoformat = false
    end, { desc = "Enable autoformat_on_save" })

    -- toggle keybind
    Snacks.toggle
      .new({
        id = "autoformat_on_save",
        name = "auto[f]ormat",
        get = function()
          return not vim.g.disable_autoformat
        end,
        set = function(enabled)
          vim.g.disable_autoformat = not enabled
        end,
      })
      :map("<leader>tf")

    return {
      formatters_by_ft = {
        lua = { "stylua" },
        python = {
          "ruff_format",
          "ruff_organize_imports",
        },
        rust = { "rustfmt" },
        nix = { "alejandra" },
      },
      format_on_save = function()
        if not vim.g.disable_autoformat then
          return { lsp_format = "fallback" }
        end
      end,
    }
  end,
  cmd = { "ConformInfo" },
}
