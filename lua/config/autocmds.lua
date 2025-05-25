-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
-- https://www.lazyvim.org/configuration/tips
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "rs" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    require("resession").save("last", { notify = false })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc(-1) == 0 then
      require("resession").load("last")
    end
  end,
})
