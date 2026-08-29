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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    local bind = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true, desc = desc })
    end

    local function open_item()
      local path = vim.fn.expand("<cfile>")
      if path ~= "" and vim.fn.isdirectory(path) == 1 then
        vim.cmd("e " .. vim.fn.fnameescape(path))
      elseif path ~= "" then
        local netrw_buf = vim.api.nvim_get_current_buf()
        vim.cmd("tabnew " .. vim.fn.fnameescape(path))
        vim.api.nvim_buf_delete(netrw_buf, { force = true })
      end
    end
    vim.keymap.set("n", "l", open_item, { buffer = true, desc = "Open file in new tab / Enter dir" })
    vim.keymap.set("n", "<CR>", open_item, { buffer = true, desc = "Open file in new tab / Enter dir" })
    bind("h", "-", "Go Up Dir")
    bind("a", "%", "Create File")
    bind("A", "d", "Create Directory")
    bind("r", "R", "Rename File/Dir")
    bind("d", "D", "Delete File/Dir")
    bind(".", "gh", "Toggle Hidden Files")
    bind("q", "<cmd>close<cr>", "Close netrw")
  end,
  desc = "Custom netrw keybindings",
})
