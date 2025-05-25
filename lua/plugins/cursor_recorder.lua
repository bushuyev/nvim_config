return {
  dir  = vim.fn.stdpath("config") .. "/lua/custom/cursor_recorder",
  name = "cursor_recorder",
  lazy = false,
  config = function()
    require("custom.cursor_recorder").setup()      -- initialise
  end,
}

