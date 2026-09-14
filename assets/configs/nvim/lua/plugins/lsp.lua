return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- for the sweet statuses
    { "j-hui/fidget.nvim", opts = {} },
    -- to setup keybinds
    "ibhagwan/fzf-lua",
    -- to register capabilities
    "saghen/blink.cmp",
  },
  config = function()
    -- start custom-lsp-attach autocommand
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("custom-lsp-attach", { clear = true }),

      -- start custom-lsp-attach callback
      callback = function(aevent)
        local client = vim.lsp.get_client_by_id(aevent.data.client_id)
        local fzf = require("fzf-lua")

        ---@param method string
        ---@param keys string
        ---@param fn function
        ---@param desc string
        ---@param mode? string | string[]
        local function map_if(method, keys, fn, desc, mode)
          if client and client:supports_method(method, aevent.buf) then
            vim.keymap.set(mode or "n", keys, fn, { buf = aevent.buf, desc = desc })
          end
        end

        -- start of keymapping block
        -- Same keys as Neovim's defaults (:h lsp-defaults), routed through fzf-lua.
        -- grn, gra, grx, K and <C-s> stay as Neovim provides them.
        map_if("textDocument/references", "grr", fzf.lsp_references, "[r]eferences")
        map_if("textDocument/definition", "grd", fzf.lsp_definitions, "[d]efinitions")
        map_if("textDocument/declaration", "grD", fzf.lsp_declarations, "[D]eclarations")
        map_if("textDocument/implementation", "gri", fzf.lsp_implementations, "[i]mplementations")
        map_if("textDocument/typeDefinition", "grt", fzf.lsp_typedefs, "[t]ype definitions")
        map_if("callHierarchy/incomingCalls", "grI", fzf.lsp_incoming_calls, "[I]ncoming calls")
        map_if("callHierarchy/outgoingCalls", "grO", fzf.lsp_outgoing_calls, "[O]utgoing calls")
        map_if("textDocument/documentSymbol", "gO", fzf.lsp_document_symbols, "document symb[O]ls")
        map_if("workspace/symbol", "gW", fzf.lsp_live_workspace_symbols, "[W]orkspace symbols")
        map_if(
          "textDocument/formatting",
          "<leader>lf",
          vim.lsp.buf.format,
          "[f]ormat",
          client and client:supports_method("textDocument/rangeFormatting", aevent.buf) and { "n", "v" } or "n"
        )
        -- end of keymapping block

        -- NOTE: Not gonna bother unbinding the keymaps when LspDetach.
      end,
      -- end custom-lsp-attach callback
    })
    -- end custom-lsp-attach autocommand

    -- start of lsp setup
    local servers = {
      -- nix
      nil_ls = {
        settings = { ["nil"] = { nix = { flake = { autoArchive = true } } } },
      },

      -- lua
      lua_ls = {},

      -- python
      ruff = {},
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy",
            },
          },
        },
      },
      ty = {},
      -- pyrefly = {},
      -- basedpyright = {
      --   settings = {
      --     basedpyright = {
      --       analysis = {
      --         typeCheckingMode = "off",
      --         diagnosticSeverityOverrides = {
      --           reportUnusedImport = "unused",
      --           reportUnusedClass = "unused",
      --           reportUnusedFunction = "unused",
      --           reportUnusedVariable = "unused",
      --           reportUnusedParameter = "unused",
      --         },
      --       },
      --     },
      --   },
      -- },

      -- misc
      harper_ls = {},
    }

    -- Configure specific servers using vim.lsp.config
    for server_name, server_opts in pairs(servers) do
      vim.lsp.config(server_name, server_opts)
      vim.lsp.enable(server_name)
    end

    -- end of lsp setup
  end,
}
