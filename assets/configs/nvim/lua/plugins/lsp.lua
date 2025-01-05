-- All LSP related garbage go here.

-- TODO: Undo everything on LSP detach

-- Autocommand to register LSP keybinds with whichkey
-- and telescope. This itself contains another autocommand
-- to highlight references on cursorhold events.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buffer = args.buf
    local wk = require("which-key")
    local telescope = require("telescope.builtin")

    ---@param method string
    ---@param keys string
    ---@param callback function
    ---@param desc string
    ---@param mode? string | string[]
    local function bind_if(method, keys, callback, desc, mode)
      if client.supports_method(method) then
        wk.add({ keys, callback, desc = desc, buffer = buffer, mode = mode or "n" })
      end
    end

    bind_if("textDocument/codeAction", "<leader>la", vim.lsp.buf.code_action, "code [a]ction")

    bind_if(
      "textDocument/formatting",
      "<leader>lf",
      vim.lsp.buf.format,
      "[f]ormat",
      client.supports_method("textDocument/rangeFormatting") and { "n", "v" } or "n"
    )

    bind_if("textDocument/hover", "<leader>lh", vim.lsp.buf.hover, "[h]over")
    bind_if("callHierarchy/incomingCalls", "<leader>li", telescope.lsp_incoming_calls, "[i]ncoming calls")
    bind_if("callHierarchy/outgoingCalls", "<leader>lo", telescope.lsp_outgoing_calls, "[o]utgoing calls")
    bind_if("textDocument/rename", "<leader>lr", vim.lsp.buf.rename, "[r]ename")
    bind_if("textDocument/documentSymbol", "<leader>ls", telescope.lsp_document_symbols, "document [s]ymbols")

    bind_if("textDocument/inlayHint", "<leader>ly", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buffer }))
    end, "inla[y] hints")

    bind_if("textDocument/references", "gr", telescope.lsp_references, "Goto or show references")
    bind_if("textDocument/definition", "gd", telescope.lsp_definitions, "Goto or show definition")
  end,
})

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    -- Which key and telescope are not strictly
    -- required for this, but they are used to
    -- setup keybinds for LSPs.
    "folke/which-key.nvim",
    "nvim-telescope/telescope.nvim",
    "saghen/blink.cmp",
  },
  opts = {
    ensure_installed = {
      "lua_ls",
      "basedpyright",
      "nil_ls",
      "rust_analyzer",
    },
    handlers = {
      -- NOTE: Default handler is disabled since
      -- some linter can also be run as LSPs
      -- which will cause multiple LSPs with
      -- overlapping functionality. Eg. basedpyright
      -- and ruff.
      -- function(server_name)
      --   require("lspconfig")[server_name].setup({})
      -- end,

      ["basedpyright"] = function()
        require("lspconfig").basedpyright.setup({
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "off",
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "unused",
                  reportUnusedClass = "unused",
                  reportUnusedFunction = "unused",
                  reportUnusedVariable = "unused",
                  reportUnusedParameter = "unused",
                },
              },
            },
          },
        })
      end,
      ["lua_ls"] = function()
        require("lspconfig").lua_ls.setup({
          -- TODO: Move nvim specific settings to here.
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        })
      end,
      ["nil_ls"] = function()
        require("lspconfig").nil_ls.setup({
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          settings = {
            ["nil"] = {
              formatting = {
                -- NOTE: nixfmt is expected to be installed (not through mason)
                command = { "nixfmt" },
              },
            },
          },
        })
      end,
      ["rust_analyzer"] = function()
        require("lspconfig").rust_analyzer.setup({
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        })
      end,
    },
  },
}
