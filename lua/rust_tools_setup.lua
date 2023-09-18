local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}




require( "rust-tools").setup({

tools = {
        runnables = {
          use_telescope = true,
        },

        autoSetHints = true,
        inlay_hints = {
          auto = true,
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> "
        }
      },
      -- all the opts to send to nvim-lspconfig
      -- these override the defaults set by rust-tools.nvim
      --
      -- REFERENCE:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      -- https://rust-analyzer.github.io/manual.html#configuration
      -- https://rust-analyzer.github.io/manual.html#features
      --
      -- NOTE: The configuration format is `rust-analyzer.<section>.<property>`.
      --       <section> should be an object.
      --       <property> should be a primitive.
      server = {
        on_attach = function(client, bufnr)
          require("shared/lsp")(client, bufnr)
          require("illuminate").on_attach(client)

          local bufopts = {
            noremap = true,
            silent = true,
            buffer = bufnr
          }
          vim.keymap.set('n', '<leader><leader>rr', "<Cmd>RustRunnables<CR>", bufopts)
          vim.keymap.set('n', 'K', "<Cmd>RustHoverActions<CR>", bufopts)
        end,
    	capabilities = capabilities,
        ["rust-analyzer"] = {
          assist = {
            importEnforceGranularity = true,
            importPrefix = "create"
          },
          cargo = { allFeatures = true, target = "wasm32-unknown-unknown" },
          checkOnSave = {
            -- default: `cargo check`
            command = "clippy",
            allFeatures = true
          },
	  procMacro = {
              enable = true
          },

        },
        inlayHints = {
          -- NOT SURE THIS IS VALID/WORKS 😬
          lifetimeElisionHints = {
            enable = true,
            useParameterNames = true
          }
        }
      }
})
