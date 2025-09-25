local term = require("term")
os.sleep(0.1)      -- Optional: give OpenOS a moment to finish drawing
term.clear()       -- Clear the screen immediately on startup

local fs = require("filesystem")
local computer = require("computer")

local SAVE_FILE = "calc_save.lua"
local history = {}
local memory = 0

local function saveData()
  local file = io.open(SAVE_FILE, "w")
  if file then
    file:write("return {\n")
    file:write("memory = " .. tostring(memory) .. ",\n")
    file:write("history = {\n")
    for _, entry in ipairs(history) do
      file:write(string.format("{expr=%q, result=%q},\n", entry.expr, entry.result))
    end
    file:write("}\n}\n")
    file:close()
  end
end

local function loadData()
  if fs.exists(SAVE_FILE) then
    local ok, data = pcall(dofile, SAVE_FILE)
    if ok and type(data) == "table" then
      memory = data.memory or 0
      history = data.history or {}
    end
  end
end

local function showHelp()
  print("===================================")
  print("      SRS-OC CALCULATOR")
  print("===================================")
  print("Type a math expression and press Enter.")
  print("Supported:")
  print("  +   Addition")
  print("  -   Subtraction")
  print("  *   Multiplication")
  print("  /   Division")
  print("  ( ) Brackets for grouping")
  print("  pi  the stupid circle shit (3.14...)")
  print("Memory: mem+ (add), mem- (subtract), mr (recall), mc (clear)")
  print("Type 'q' to quit.")
  print("-------------------------------")
  print("History (last 10):")
  for i = math.max(1, #history-9), #history do
    print(string.format("%d: %s = %s", i, history[i].expr, history[i].result))
  end
  print("-------------------------------")
end

loadData()
term.clear() -- Clear the screen before starting

while true do
  term.clear()
  showHelp()
  io.write("Expression: ")
  local input = io.read()
  if input == "q" then break end

  -- Memory commands
  if input == "mr" then
    print("Memory: " .. tostring(memory))
    computer.beep()
    print("Press Enter to continue...")
    io.read()
  elseif input == "mc" then
    memory = 0
    print("Memory cleared.")
    computer.beep()
    print("Press Enter to continue...")
    io.read()
  elseif input:match("^mem%+") then
    local val = tonumber(input:match("^mem%+%s*(.*)"))
    if val then
      memory = memory + val
      print("Added to memory. Memory: " .. tostring(memory))
    else
      print("Usage: mem+ <number>")
    end
    computer.beep()
    print("Press Enter to continue...")
    io.read()
  elseif input:match("^mem%-") then
    local val = tonumber(input:match("^mem%-%s*(.*)"))
    if val then
      memory = memory - val
      print("Subtracted from memory. Memory: " .. tostring(memory))
    else
      print("Usage: mem- <number>")
    end
    computer.beep()
    print("Press Enter to continue...")
    io.read()
  else
    -- Only allow numbers, operators, parentheses, pi, and memory for safety
    if not input:match("^[%d%+%-%*/%(%)%.%smpi]+$") then
      print("Invalid characters in expression.")
      os.sleep(1.5)
    else
      -- Replace 'pi' with math.pi and 'mem' with memory value
      local safeInput = input:gsub("pi", tostring(math.pi))
      safeInput = safeInput:gsub("mem", tostring(memory))
      local func, err = load("return " .. safeInput)
      if not func then
        print("Error: " .. tostring(err))
        os.sleep(1.5)
      else
        local ok, result = pcall(func)
        if ok then
          print("Result: " .. tostring(result))
          table.insert(history, {expr = input, result = tostring(result)})
          if #history > 10 then table.remove(history, 1) end
        else
          print("Error: " .. tostring(result))
        end
        computer.beep()
        print("Press Enter to continue...")
        io.read()
      end
    end
  end
  saveData()
end

term.clear() -- Clear the screen
