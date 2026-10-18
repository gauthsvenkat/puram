return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    -- HACK: tree-sitter-just can't parse `mod::recipe` in aliases and dependencies.
    -- Use the parser and queries from https://github.com/casey/tree-sitter-just/pull/204.
    -- Remove once it's merged and nvim-treesitter bumps its pin.
    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      callback = function()
        local info = require("nvim-treesitter.parsers").just.install_info
        info.url = "https://github.com/tkatter/tree-sitter-just"
        info.revision = "912ac5a7b763af3ac488dbfaafb05fde7e926ece"
        info.queries = "queries/just"
      end,
    })

    ts.install({
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "python",
      "rust",
      "nix",
      "bash",
      "json",
      "toml",
      "yaml",
    })

    local function attach(buf, language)
      if not vim.treesitter.language.add(language) then
        return
      end
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      vim.treesitter.start(buf, language)

      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

      if vim.treesitter.query.get(language, "indents") then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    local available = ts.get_available()

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", {}),
      callback = function(event)
        local buf, filetype = event.buf, event.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end

        if vim.tbl_contains(available, language) then
          ts.install(language):await(function()
            attach(buf, language)
          end)
        else
          attach(buf, language)
        end
      end,
    })
  end,
}
