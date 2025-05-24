-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map("n", "<leader>mf", function() LazyVim.format.toggle() end, { desc = "Toggle format" })
map("n", "<leader>mw", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace Symbols" })
map("n", "<leader>md", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })
map("n", "<leader>mc", "<cmd>Telescope lsp_definitions<CR>", { desc = "Declarations (Definitions)" })
map("n", "<leader>mt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Type Definitions" })
map("n", "<leader>me", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
map("n", "<leader>f", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
