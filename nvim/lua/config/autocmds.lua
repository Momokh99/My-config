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

autocmd("FileType", {
	group = mygroup,
	pattern = "qf,help,man",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
	end,
})
