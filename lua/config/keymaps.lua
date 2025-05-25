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

-- map("n", "<leader>qs", function() require("resession").save() end, { desc = "Save Session" })
map("n", "<leader>qv", function() require("resession").save(nil, { notify = true }) end, { desc = "Save Session" })
map("n", "<leader>ql", function() require("resession").load() end, { desc = "Load Session" })
map("n", "<leader>qd", function() require("resession").delete() end, { desc = "Delete Session" })

local cr = require("custom.cursor_recorder")
map("n", "<C-h>", cr.jump_back,    { desc = "Cursor history back" })
map("n", "<C-l>", cr.jump_forward, { desc = "Cursor history forward" })
