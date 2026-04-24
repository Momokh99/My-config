local M = {}

--run dif files
local runComands = {
  --scripting lang
  python = "python3",
  javascript = "node",
  go = "so run",
  sh = "bash",
  lua = "lua",
  --compiled lang
  c = "gcc '%:p' -o '%:p:r' && '%:p:r'",
  cpp = "g++ '%:p' -o '%:p:r' && ':p:r'",
  asm = "nasm -f elf64 '%:p' -o '%:p:r.o' && '%:p:r.o' -o '%:p:r' && '%:p:r'",
  --web lang
  html = "xdg-open",
}

function M.runCurentFile()
  local fileType = vim.bo.filetype
  local filePath = vim.fn.expand("%:p")
  local cmd = runComands[fileType]
  if not cmd then
    print("no runner configured for the type: " .. fileType)
    return
  end
  if fileType == "html" then
    vim.fn.jobstart({ cmd, filePath }, { detach = true })
  else
    local finalCmd = cmd:gsub("%%:p:r", vim.fn.expand("%:p:r"))
    --compiled C C++ ...
    finalCmd = finalCmd:gsub("%%:p", filePath)
    if not cmd:find("%%") then
      --Python,lua,bash...
      finalCmd = cmd .. " " .. filePath
    end
    --terminal
    vim.cmd("botright split | term " .. finalCmd)
    vim.cmd("startinsert")
  end
end

return M
