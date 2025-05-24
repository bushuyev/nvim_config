return {
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup({
        debug = false,
        default_mappings = true,
        stack_floating_preview_windows = false,
        dismiss_on_move = false,
      })
    end,
  },
}
