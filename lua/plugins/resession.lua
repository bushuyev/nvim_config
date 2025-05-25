return {
  "stevearc/resession.nvim",
  opts = {},
  config = function(_, opts)
    require("resession").setup(opts)

    -- Optional: Save session on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        require("resession").save("last", { notify = false })
      end,
    })
  end,
}
