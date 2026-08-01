local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local mygroup = augroup("user_cmds", { clear = true })

autocmd("TextYankPost", {
	group = mygroup,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

autocmd("BufWritePre", {
	group = mygroup,
	callback = function()
		vim.fn.mkdir(vim.fn.expand("<afile>:p:h"), "p")
	end,
})

-- Automatically format Lua and JSON on save using native LSP
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.json" },
  callback = function(args)
    vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
  end,
  desc = "Format Lua and JSON on save via native LSP",
})

-- Native auto-pairs for quotes and brackets
local pairs_map = {
  ["("] = "()",
  ["["] = "[]",
  ["{"] = "{}",
  ['"'] = '""',
  ["'"] = "''",
}
for open, close in pairs(pairs_map) do
  vim.keymap.set("i", open, close .. "<Left>", { noremap = true, silent = true })
end


autocmd("FileType", {
	group = mygroup,
	pattern = "qf,help,man",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
	end,
})

-- Clean up netrw buffer keymaps using an autocmd
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    local bind = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true, desc = desc })
    end

    -- Navigation
    bind("l", "<CR>", "Open File / Enter Dir")
    bind("h", "-", "Go Up Dir")

    -- File / Directory Operations
    bind("a", "%", "Create File")
    bind("A", "d", "Create Directory")
    bind("r", "R", "Rename File/Dir")
    bind("d", "D", "Delete File/Dir")

    -- Quick Toggle Hidden Files
    bind(".", "gh", "Toggle Hidden Files")

    -- Close netrw easily
    bind("q", "<cmd>close<cr>", "Close netrw")
  end,
  desc = "Custom netrw keybindings",
})
