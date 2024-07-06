-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

--map("n", "<leader>md", function() LazyVim.format.toggle() end, { desc = "XXXXXXXXX" })
map("n", "<leader>mw", function() require("fzf-lua").lsp_workspace_symbols() end, { desc = "Workspace symbols" })
map("n", "<leader>md", function() require("fzf-lua").lsp_document_symbols() end, { desc = "Document Symbols" })
map("n", "<leader>mc", function() require("fzf-lua").lsp_declarations() end, { desc = "Declarations" })
map("n", "<leader>mt", function() require("fzf-lua").lsp_typedefs() end, { desc = "Type Definitions" })
