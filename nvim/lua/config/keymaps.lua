local keymap = vim.keymap.set

-- Quick save / quit
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Clear search highlighting with ESC (normal + visual mode, noremap to avoid conflicts)
keymap({ "n", "x" }, "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true })



-- Open netrw in current buffer
keymap("n", "<leader>eb", "<cmd>Explore<cr>", { desc = "Explore Buffer (netrw)" })

-- Open netrw in vertical split
keymap("n", "<leader>ev", "<cmd>Vexplore<cr>", { desc = "Explore Vertical Split (netrw)" })

-- Open netrw in horizontal split
keymap("n", "<leader>eh", "<cmd>Hexplore<cr>", { desc = "Explore Horizontal Split (netrw)" })

-- Buffer Navigation
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete/Close Buffer" })
keymap("n", "<leader>bl", "<cmd>ls<cr>", { desc = "List Buffers" })
keymap("n", "<H>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap("n", "<L>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
