local M = {}

local runners = {
  -- scripting
  python = "python3",
  javascript = "node",
  typescript = "tsx",
  sh = "bash",
  zsh = "zsh",
  lua = "lua",
  ruby = "ruby",
  php = "php",
  go = "go run",
  rust = "cargo run",
  java = "java",
  -- compiled
  c = "gcc %:p -o %:p:r && %:p:r",
  cpp = "g++ %:p -o %:p:r && %:p:r",
  asm = "nasm -f elf64 %:p -o %:p:r.o && ld %:p:r.o -o %:p:r && %:p:r",
  -- web
  html = "xdg-open",
}

local term_buf = nil

function M.runCurrentFile()
  local ft = vim.bo.filetype
  local cmd = runners[ft]
  if not cmd then
    vim.notify("No runner configured for type: " .. ft, vim.log.levels.WARN)
    return
  end

  vim.cmd("silent update")

  local path = vim.fn.shellescape(vim.fn.expand("%:p"))
  local base = vim.fn.shellescape(vim.fn.expand("%:p:r"))
  local full = cmd:gsub("%%:p", path):gsub("%%:p:r", base)
  if not cmd:find("%%") then
    full = cmd .. " " .. path
  end

  if ft == "html" then
    vim.fn.jobstart(full, { detach = true })
    return
  end

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("botright split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.fn.chansend(vim.bo[term_buf].channel, full .. "\n")
end

return M
