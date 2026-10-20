# Neovim config

- Neovim 0.12, Lua, `lazy.nvim`. `init.lua` -> `lua/config/{options,lazy}.lua` -> one plugin spec per file in `lua/plugins/`.
- External tools (LSPs, formatters, linters) come from Nix, not Mason. Don't add installers.

# Conventions

- Prefer Neovim defaults. Don't restate default options or default keymaps; delete config that a newer Neovim made redundant.
- Follow community patterns (kickstart.nvim, LazyVim) and check current plugin docs before changing setup. Cite the source.
- Keymaps live in the plugin spec that provides them. Leader groups are declared in `lua/plugins/which-key.lua` with a `-- bindings defined in ./x.lua` comment.
- Ex-command mappings use `require("utils").cmd`. Descriptions use the `[x]` mnemonic style.
- Pickers are `Snacks.picker`. LSP navigation uses Neovim's default `gr*` keys routed through it.

# Verify

- Test headless: `nvim --headless -c '<lua>' -c 'qa!'`. Plugins on `VeryLazy` need `require("lazy").load({ plugins = { ... } })` after `VimEnter`.
- `stylua --check` before commit; `prek` hooks run stylua and whitespace checks.
