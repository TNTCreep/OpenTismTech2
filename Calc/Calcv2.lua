local term = require("term")
local fs = require("filesystem")
local computer = require("computer")

os.sleep(0.1)
pcall(function() term.clear() end)

local SAVE_FILE = "calc_save.lua"
local history = {}
local memory = 0
local ans = 0

-- Unit tables for Minecraft blocks and buckets
local blockUnits = {
  {"Blocks",      1},
  {"CentBlocks",  10},
  {"KiloBlocks",  100},
  {"MegaBlocks",  1000},
  {"GigaBlocks",  10000},
  {"TetraBlocks", 100000},
  {"PentaBlocks", 1000000},
  {"HexaBlocks",  10000000},
  {"HepaBlocks",  100000000},
  {"OctaBlocks",  1000000000},
  {"NonaBlocks",  10000000000},
  {"DecaBlocks",  100000000000}
}

local bucketUnits = {
  {"MiliBuckets", 0.001},
  {"Buckets",      1},
  {"CentBuckets",  10},
  {"KiloBuckets",  100},
  {"MegaBuckets",  1000},
  {"GigaBuckets",  10000},
  {"TetraBuckets", 100000},
  {"PentaBuckets", 1000000},
  {"HexaBuckets",  10000000},
  {"HepaBuckets",  100000000},
  {"OctoBuckets",  1000000000},
  {"NonaBuckets",  10000000000},
  {"DecaBuckets",  100000000000}
}

-- Settings table
local settings = {
  historyLength = 10,
  sound = true,
  rounding = false,
  decimals = 2,
  unitSystem = "Blocks", -- "Blocks" or "Buckets"
  blockUnit = 1, -- index in blockUnits
  bucketUnit = 2, -- index in bucketUnits (default to Buckets)
  showUnits = true
}

-- Logging (optional, remove if not needed)
local function logEvent(msg)
  -- Uncomment below to enable logging to a file
  -- local file = io.open("calc_log.txt", "a")
  -- if file then
  --   file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
  --   file:close()
  -- end
end

local function saveData()
  local file = io.open(SAVE_FILE, "w")
  if file then
    file:write("return {\n")
    file:write("memory = " .. tostring(memory) .. ",\n")
    file:write("history = {\n")
    for _, entry in ipairs(history) do
      file:write(string.format("{expr=%q, result=%q},\n", entry.expr, entry.result))
    end
    file:write("},\n")
    file:write("settings = {historyLength = " .. tostring(settings.historyLength) ..
      ", sound = " .. tostring(settings.sound) ..
      ", rounding = " .. tostring(settings.rounding) ..
      ", decimals = " .. tostring(settings.decimals) ..
      ", unitSystem = %q" ..
      ", blockUnit = " .. tostring(settings.blockUnit) ..
      ", bucketUnit = " .. tostring(settings.bucketUnit) ..
      ", showUnits = " .. tostring(settings.showUnits) .. "}\n", settings.unitSystem)
    file:write("}\n")
    file:close()
  end
end

local function loadData()
  if fs.exists(SAVE_FILE) then
    local ok, data = pcall(dofile, SAVE_FILE)
    if ok and type(data) == "table" then
      memory = data.memory or 0
      history = data.history or {}
      if data.settings then
        settings.historyLength = data.settings.historyLength or 10
        settings.sound = data.settings.sound == nil and true or data.settings.sound
        settings.rounding = data.settings.rounding or false
        settings.decimals = data.settings.decimals or 2
        settings.unitSystem = data.settings.unitSystem or "Blocks"
        settings.blockUnit = data.settings.blockUnit or 1
        settings.bucketUnit = data.settings.bucketUnit or 2
        settings.showUnits = data.settings.showUnits == nil and true or data.settings.showUnits
      end
    end
  end
end

local function showSettings()
  while true do
    term.clear()
    print("========== SETTINGS ==========")
    print("1. History Length: " .. tostring(settings.historyLength))
    print("2. Sound: " .. (settings.sound and "On" or "Off"))
    print("3. Auto Rounding: " .. (settings.rounding and ("On ("..settings.decimals.." decimals)") or "Off"))
    print("4. Unit System: " .. settings.unitSystem)
    if settings.unitSystem == "Blocks" then
      print("5. Block Unit: " .. blockUnits[settings.blockUnit][1])
    else
      print("5. Bucket Unit: " .. bucketUnits[settings.bucketUnit][1])
    end
    print("6. Show Units: " .. (settings.showUnits and "On" or "Off"))
    print("Type the number to change, or 'back' to return.")
    io.write("Choice: ")
    local choice = io.read()
    if choice == "1" then
      io.write("Enter new history length (1-100): ")
      local len = tonumber(io.read())
      if len and len >= 1 and len <= 100 then
        settings.historyLength = math.floor(len)
        print("History length set to " .. settings.historyLength)
      else
        print("Invalid number.")
      end
      os.sleep(1)
    elseif choice == "2" then
      io.write("Turn sound on or off (on/off): ")
      local snd = io.read()
      if snd == "on" then
        settings.sound = true
        print("Sound enabled.")
      elseif snd == "off" then
        settings.sound = false
        print("Sound disabled.")
      else
        print("Invalid input.")
      end
      os.sleep(1)
    elseif choice == "3" then
      io.write("Auto rounding on or off (on/off): ")
      local rnd = io.read()
      if rnd == "on" then
        settings.rounding = true
        io.write("How many decimals? (0-10): ")
        local dec = tonumber(io.read())
        if dec and dec >= 0 and dec <= 10 then
          settings.decimals = math.floor(dec)
          print("Rounding set to " .. settings.decimals .. " decimals.")
        else
          print("Invalid number, using 2 decimals.")
          settings.decimals = 2
        end
      elseif rnd == "off" then
        settings.rounding = false
        print("Auto rounding disabled.")
      else
        print("Invalid input.")
      end
      os.sleep(1)
    elseif choice == "4" then
      io.write("Select unit system (Blocks/Buckets): ")
      local sys = io.read()
      if sys:lower() == "blocks" then
        settings.unitSystem = "Blocks"
        print("Unit system set to Blocks.")
      elseif sys:lower() == "buckets" then
        settings.unitSystem = "Buckets"
        print("Unit system set to Buckets.")
      else
        print("Invalid unit system.")
      end
      os.sleep(1)
    elseif choice == "5" then
      if settings.unitSystem == "Blocks" then
        print("Available Block Units:")
        for i, unit in ipairs(blockUnits) do
          print(i .. ". " .. unit[1] .. " (1:" .. unit[2] .. ")")
        end
        io.write("Select unit number: ")
        local idx = tonumber(io.read())
        if idx and blockUnits[idx] then
          settings.blockUnit = idx
          print("Block unit set to " .. blockUnits[idx][1])
        else
          print("Invalid unit.")
        end
      else
        print("Available Bucket Units:")
        for i, unit in ipairs(bucketUnits) do
          print(i .. ". " .. unit[1] .. " (1:" .. unit[2] .. ")")
        end
        io.write("Select unit number: ")
        local idx = tonumber(io.read())
        if idx and bucketUnits[idx] then
          settings.bucketUnit = idx
          print("Bucket unit set to " .. bucketUnits[idx][1])
        else
          print("Invalid unit.")
        end
      end
      os.sleep(1)
    elseif choice == "6" then
      io.write("Show units in results? (on/off): ")
      local su = io.read()
      if su == "on" then
        settings.showUnits = true
        print("Units will be shown in results.")
      elseif su == "off" then
        settings.showUnits = false
        print("Units will NOT be shown in results.")
      else
        print("Invalid input.")
      end
      os.sleep(1)
    elseif choice == "back" then
      break
    else
      print("Invalid choice.")
      os.sleep(1)
    end
  end
end

local function showStatus()
  print("===================================")
  print("      SRS-OC CALCULATOR")
  print("===================================")
  print("Type a math expression and press Enter.")
  print("Supported: + - * / ^ sqrt(x) pow(a,b) abs(x) log(x) exp(x)")
  print("           sin(x) cos(x) tan(x) (x in radians)")
  print("           pi, e, ans (last answer), mem (memory)")
  print("           √(x) also works for square root")
  print("Memory: mem+ (add), mem- (subtract), mr (recall), mc (clear)")
  print("Other: clearhistory, settings, q (quit)")
  print("-------------------------------")
  if settings.showUnits then
    if settings.unitSystem == "Blocks" then
      print("Block Unit: " .. blockUnits[settings.blockUnit][1] .. " (1:" .. blockUnits[settings.blockUnit][2] .. ")")
    else
      print("Bucket Unit: " .. bucketUnits[settings.bucketUnit][1] .. " (1:" .. bucketUnits[settings.bucketUnit][2] .. ")")
    end
  end
  print("History (last " .. tostring(settings.historyLength) .. "):")
  for i = math.max(1, #history-settings.historyLength+1), #history do
    print(string.format("%d: %s = %s", i, history[i].expr, history[i].result))
  end
  print("-------------------------------")
end

loadData()
pcall(function() term.clear() end)

while true do
  term.clear()
  showStatus()
  io.write("Expression: ")
  local input = io.read()
  if input == "q" then break end

  if input == "settings" then
    showSettings()
    saveData()
  elseif input == "clearhistory" then
    history = {}
    print("History cleared.")
    logEvent("History cleared by user.")
    if settings.sound then computer.beep() end
    print("Press Enter to continue...")
    io.read()
  elseif input == "mr" then
    print("Memory: " .. tostring(memory))
    if settings.sound then computer.beep() end
    print("Press Enter to continue...")
    io.read()
  elseif input == "mc" then
    memory = 0
    print("Memory cleared.")
    if settings.sound then computer.beep() end
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
    if settings.sound then computer.beep() end
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
    if settings.sound then computer.beep() end
    print("Press Enter to continue...")
    io.read()
  else
    -- Only allow safe characters
    if not input:match("^[%w%+%-%*/%%%^%(%)%.%s,√]+$") then
      print("Invalid characters in expression.")
      logEvent("Invalid input: " .. input)
      os.sleep(1.5)
    else
      -- Replace constants and variables
      local safeInput = input
      safeInput = safeInput:gsub("pi", tostring(math.pi))
      safeInput = safeInput:gsub("e", tostring(math.exp(1)))
      safeInput = safeInput:gsub("mem", tostring(memory))
      safeInput = safeInput:gsub("ans", tostring(ans))
      safeInput = safeInput:gsub("√%s*%(([^%)]+)%)", "sqrt(%1)") -- Unicode sqrt(x) support

      -- Allow math functions
      local env = {
        sqrt = math.sqrt, pow = math.pow, abs = math.abs, log = math.log,
        exp = math.exp, sin = math.sin, cos = math.cos, tan = math.tan,
        pi = math.pi, e = math.exp(1)
      }

      local func, err = load("return " .. safeInput, "calc", "t", env)
      if not func then
        print("Error: " .. tostring(err))
        logEvent("Parse error: " .. tostring(err))
        os.sleep(1.5)
      else
        local ok, result = pcall(func)
        if ok then
          -- Auto rounding if enabled and result is a number
          if settings.rounding and type(result) == "number" then
            local fmt = "%." .. tostring(settings.decimals) .. "f"
            result = tonumber(string.format(fmt, result))
          end
          -- Unit conversion if result is a number and showUnits is enabled
          if type(result) == "number" and settings.showUnits then
            local unitName, unitDiv
            if settings.unitSystem == "Blocks" then
              unitName = blockUnits[settings.blockUnit][1]
              unitDiv = blockUnits[settings.blockUnit][2]
            else
              unitName = bucketUnits[settings.bucketUnit][1]
              unitDiv = bucketUnits[settings.bucketUnit][2]
            end
            print("Result: " .. tostring(result) .. " (" .. tostring(result / unitDiv) .. " " .. unitName .. ")")
            ans = result
            table.insert(history, {expr = input, result = tostring(result) .. " (" .. tostring(result / unitDiv) .. " " .. unitName .. ")"})
          else
            print("Result: " .. tostring(result))
            ans = result
            table.insert(history, {expr = input, result = tostring(result)})
          end
          if #history > settings.historyLength then table.remove(history, 1) end
          logEvent(input .. " = " .. tostring(result))
        else
          print("Error: " .. tostring(result))
          logEvent("Calc error: " .. tostring(result))
        end
        if settings.sound then computer.beep() end
        print("Press Enter to continue...")
        io.read()
      end
    end
  end
  saveData()
end

term.clear()
