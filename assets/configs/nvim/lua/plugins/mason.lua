return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { { "mason-org/mason.nvim", opts = {} } },
  opts = {
    ensure_installed = {
      -- python
      { "basedpyright" },
      { "ruff" },
      { "mypy" },

      -- rust
      { "rust_analyzer" },
      { "rustfmt" },

      -- lua
      { "lua_ls" },
      { "stylua" },

      -- nix
      { "nil_ls" },
      { "alejandra" },
    },
  },
}
