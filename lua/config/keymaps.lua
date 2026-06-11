-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "W", "<leader>bd", { remap = true, desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
vim.keymap.set("n", "N", "<cmd>enew<cr>", { desc = "New Buffer" })
