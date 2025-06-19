return {
  "jay-babu/mason-nvim-dap.nvim",
  lazy = false,                     -- ← guarantees first-class loading
  dependencies = "williamboman/mason.nvim",
  opts = { ensure_installed = { "codelldb" } },
}
