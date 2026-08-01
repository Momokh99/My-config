vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.tabstop = 4 -- Number of spaces tabs count for
opt.shiftwidth = 4 -- Size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically
opt.ignorecase = true -- Case-insensitive searching...
opt.smartcase = true -- ...unless \C or capital in search
opt.termguicolors = true -- True color support
opt.signcolumn = "yes" -- Always show sign column (prevents text jumping)
opt.updatetime = 250 -- Faster completion / UI response
opt.clipboard = "unnamedplus" -- Sync with system clipboard
