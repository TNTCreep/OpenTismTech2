print("loading...")

local term = require("term")
local shell = require("shell")
local fs = require("filesystem")
local sh = require("sh")

local wd = shell.getWorkingDirectory()

term.clear()
print("TherTerm 1.0.0")
print("For help, type help\nTo exit, type exit")

while true do
  io.write(shell.getWorkingDirectory() .. " -> ")
  local command = io.read()
  if command == "exit" then
    break
  elseif command == "help" then
    print("-- HELP --")
    print("Commands: \nhelp - Shows this menu\nexit - closes the command prompt")
    print("-- HELP --")
  elseif command:find("cd ") then
    local newDir = command:sub(4)
    if not newDir:find("/") then
      shell.setWorkingDirectory(shell.getWorkingDirectory() .. "/" .. newDir)
    else
      shell.setWorkingDirectory(newDir)
    end
  else
    shell.execute(command)
  end
end
