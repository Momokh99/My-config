-- Enable global statusline across all splits
vim.opt.laststatus = 3

-- Vim mode mapping table
local modes = {
  ["n"]  = "NORMAL",
  ["no"] = "N-OPERATOR",
  ["v"]  = "VISUAL",
  ["V"]  = "V-LINE",
  ["\22"] = "V-BLOCK",
  ["s"]  = "SELECT",
  ["S"]  = "S-LINE",
  ["\19"] = "S-BLOCK",
  ["i"]  = "INSERT",
  ["ic"] = "INSERT",
  ["R"]  = "REPLACE",
  ["Rv"] = "V-REPLACE",
  ["c"]  = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"]  = "PROMPT",
  ["rm"] = "MORE",
  ["r?"] = "CONFIRM",
  ["!"]  = "SHELL",
  ["t"]  = "TERMINAL",
}

-- Native Statusline Generator
function _G.statusline()
  -- Current Mode
  local mode_code = vim.api.nvim_get_mode().mode
  local mode = string.format(" %#ModeMsg# [%s] %#Normal#", modes[mode_code] or mode_code:upper())

  -- Relative Filepath & Modified Flag (%f = path, %m = [+], %r = [RO])
  local filepath = " %f %m%r "

  -- Git Branch (read directly from git)
  local head = vim.fn.system("git branch --show-current"):gsub("\n", "")
  local git = head ~= "" and string.format("%%#Comment#( %s)%%#Normal# ", head) or ""

  -- LSP Diagnostics Count
  local diagnostics = ""
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

  if errors > 0 then
    diagnostics = diagnostics .. string.format(" %%#DiagnosticError#E:%d%%#Normal#", errors)
  end
  if warnings > 0 then
    diagnostics = diagnostics .. string.format(" %%#DiagnosticWarn#W:%d%%#Normal#", warnings)
  end

  -- Alignment separator (pushes remaining items to the right)
  local align = "%="

  -- Filetype & Encoding
  local filetype = vim.bo.filetype ~= "" and string.format("[%s] ", vim.bo.filetype) or ""

  -- Line, Column, and Percentage
  local location = " %l:%c  %P "

  return table.concat({
    mode,
    git,
    filepath,
    diagnostics,
    align,
    filetype,
    location,
  })
end

-- Attach the Lua function to statusline
vim.opt.statusline = "%!v:lua.statusline()"
