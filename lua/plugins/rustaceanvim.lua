return {
  "mrcjkb/rustaceanvim",
  version = "^4", -- Recommended
  ft = { "rust" },
  opts = {
    server = {
      on_attach = function(_, bufnr)

        vim.keymap.set("n", "<leader>cR", function()
          vim.cmd.RustLsp("codeAction")
        end, { desc = "Code Action", buffer = bufnr })

       --vim.keymap.set("n", "<leader>mT", function()
       --  vim.cmd.RustLsp("runnables", "--no-capture")
       --end, { desc = "Rust Runnables", buffer = bufnr })


        vim.keymap.set("n", "<leader>dr", function()
          vim.cmd.RustLsp("debuggables")
        end, { desc = "Rust Debuggables", buffer = bufnr })

	vim.lsp.inlay_hint.enable(true)

      end,
      default_settings = {
        -- rust-analyzer language server configuration
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = false,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Add clippy lints for Rust.
          checkOnSave = true,
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
	  diagnostics = {
              experimental = {
                  enable = false 
              }
          }
        },
      },
    },
  },
  config = function(_, opts)
    vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    if vim.fn.executable("rust-analyzer") == 0 then
      LazyVim.error(
        "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
        { title = "rustaceanvim" }
      )
    end
  end,
} 
