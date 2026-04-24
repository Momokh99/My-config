-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local runner = require("config.my_runner")
vim.keymap.set("n", "<leader><CR>", runner.runCurentFile, { desc = "Run current file" })
