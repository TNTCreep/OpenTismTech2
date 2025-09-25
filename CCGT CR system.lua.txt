
local component = require("component")
local event = require("event")
local term = require("term")

term.clear()
print("Loading...")

-- Peripherals
local gpu = component.gpu
local battery = {}
local battery_present = true
local c = 1
for add, _ in component.list("ntm_energy_storage") do
  battery[c] = component.proxy(add)
  c = c + 1
end
if (#battery >= 1) then
  battery = battery[1]
else
  battery = nil
  battery_present = false
end

local turbines = {}
c = 1
for add, _ in component.list("ntm_gas_turbine") do
  turbines[c] = component.proxy(add)
  c = c + 1
end

-- Global vars
local delta_program = 0.1
local max = 0.8
local min = 0.2

local temp = {0}
local battery_energy = {}
local battery_percentage = 0.0
local blink = true
local key = {}
local input = ""
local auto = {}
for i = 1, #turbines do auto[i] = true end

local activation = false
local turbine_index = 0
local turbine_set = 0
local keywords = {}
local x, y = term.getCursor()

-- Human-readable HE unit scale
local function x3_scale(n)
  local scale = {" ", "k", "M", "G", "T"}
  local i = 1
  while math.abs(n) >= 1000 and i < #scale do
    n = n / 1000
    i = i + 1
  end
  return string.format("%.1f %s", n, scale[i])
end

local function time(mask)
  return tonumber(os.date(mask))
end

local function screen_divider(str)
  local W = term.window.width
  local X, Y = term.getCursor()
  for i = X, W - #str, #str do term.write(str) end
  X, Y = term.getCursor()
  if X < W then
    for i = 1, W - X + 1 do term.write(str:sub(i, i)) end
  end
  if #str == 1 then term.write(str) end
  print()
end

local function segment(input)
  local result, word = {}, ""
  for i = 1, #input do
    local char = input:sub(i, i)
    if char == " " then
      if #word > 0 then table.insert(result, word) end
      word = ""
    else
      word = word .. char
    end
  end
  if #word > 0 then table.insert(result, word) end
  return result
end

local function start_all(arr)
  for i, t in ipairs(arr) do
    local f = {t.getFluid()}
    local fuel = (f[1]/f[2] > 0 and f[3]/f[4] > 0)
    if t.getState() == 0 and fuel then t.start() end
  end
end

local function stop_all(arr)
  for _, t in ipairs(arr) do t.stop() end
end

local function print_turbine(t, i)
  local fluid = {t.getFluid()}
  local energy = t.getPower()
  local status = ({[-1]="Starting...", [0]="Offline", [1]="Online"})[t.getState()] or "Error"
  print(string.format("Turbine %d", i))
  print(string.format(" Fuel Type : %s", t.getType()))
  print(string.format(" Status     : %s", status))
  print(string.format(" Throttle   : %d%%", t.getThrottle()))
  print(string.format(" Fuel       : %.1f%%", fluid[1] / fluid[2] * 100))
  print(string.format(" Lubricant  : %.1f%%", fluid[3] / fluid[4] * 100))
  print(string.format(" Energy     : %s HE", x3_scale(energy)))
  print(string.format(" Water      : %.1f%%", fluid[5] / fluid[6] * 100))
  print(string.format(" Steam      : %.1f%%", fluid[7] / fluid[8] * 100))
end

term.clear()
local w, h = term.window.width, term.window.height

while true do
  if battery_present then
    battery_energy = {battery.getInfo()}
    battery_percentage = battery_energy[1] / battery_energy[2]
  else
    battery_percentage = -0.01
  end

  if activation and battery_present then
    for i, t in ipairs(turbines) do
      if auto[i] then
        if battery_percentage >= max and t.getState() == 1 then
          t.stop()
        elseif battery_percentage <= min and t.getState() == 0 then
          local fluid = {t.getFluid()}
          if (fluid[1]/fluid[2] > 0 and fluid[3]/fluid[4] > 0) then t.start() end
        end
      end
    end
  end

  key = {event.pull(0.05, "key")}
  if key[3] then
    if key[1] == "key_down" then
      if key[3] == 0 then
        input = ""
      elseif key[3] == 8 then
        input = input:sub(1, -2)
      elseif key[3] >= 32 and key[3] <= 126 then
        input = input .. string.char(key[3])
      elseif key[3] == 13 then
        keywords = segment(input:lower())
        input = ""
        term.setCursor(x, y)
        for i = y, h - 1 do screen_divider(" ") end
        term.setCursor(x, y)

        -- === Command Handling ===
        if (keywords[1] == "get" and keywords[2] == "esbsr") then
          print("ESBSR System Readout:")
          print(string.format("  Status      : %s", activation and "ENABLED" or "DISABLED"))
          print(string.format("  Max Trigger : %.1f%%", max * 100))
          print(string.format("  Min Trigger : %.1f%%", min * 100))
          for i = 1, #turbines do
            print(string.format("  Turbine %d -> AUTO: %5s", i, tostring(auto[i])))
          end
          screen_divider("-")

        elseif (keywords[1] == "set") then
          if keywords[2] == "min" and tonumber(keywords[3]) then
            min = tonumber(keywords[3]) / 100
            print("Min threshold set to " .. (min * 100) .. "%")
          elseif keywords[2] == "max" and tonumber(keywords[3]) then
            max = tonumber(keywords[3]) / 100
            print("Max threshold set to " .. (max * 100) .. "%")
          elseif keywords[2] == "throttle" and tonumber(keywords[3]) and tonumber(keywords[4]) then
            local t_index = tonumber(keywords[3])
            local throttle = tonumber(keywords[4])
            if turbines[t_index] then
              turbines[t_index].setThrottle(throttle)
              print(string.format("Throttle set to %d%% on Turbine %d", throttle, t_index))
            else
              print("Invalid turbine index.")
            end
          elseif keywords[2] == "auto" and keywords[3] and keywords[4] then
            local t_index = tonumber(keywords[3])
            local value = keywords[4]
            if value == "true" or value == "false" then
              if t_index and turbines[t_index] then
                auto[t_index] = (value == "true")
                print(string.format("Auto for Turbine %d set to %s", t_index, tostring(auto[t_index])))
              elseif keywords[3] == "all" then
                for i = 1, #turbines do auto[i] = (value == "true") end
                print(string.format("Auto set to %s for all turbines", tostring(value)))
              else
                print("Invalid turbine index or value.")
              end
            else
              print("Auto value must be 'true' or 'false'.")
            end
          else
            print("Invalid set command. Try 'help'.")
          end

        elseif keywords[1] == "get" and keywords[2] == "turbine" then
          if keywords[3] == "all" then
            for i, t in ipairs(turbines) do
              print_turbine(t, i)
              screen_divider("-")
            end
          elseif tonumber(keywords[3]) and turbines[tonumber(keywords[3])] then
            local idx = tonumber(keywords[3])
            print_turbine(turbines[idx], idx)
          else
            print("Invalid turbine index or use 'all'")
          end

        elseif (keywords[1] == "start") then
          if keywords[2] == "all" then
            start_all(turbines)
            print("All turbines started.")
          elseif tonumber(keywords[2]) and turbines[tonumber(keywords[2])] then
            local idx = tonumber(keywords[2])
            turbines[idx].start()
            print("Turbine " .. idx .. " started.")
          else
            print("Invalid turbine index or use 'all'")
          end

        elseif (keywords[1] == "stop") then
          if keywords[2] == "all" then
            stop_all(turbines)
            print("All turbines stopped.")
          elseif tonumber(keywords[2]) and turbines[tonumber(keywords[2])] then
            local idx = tonumber(keywords[2])
            turbines[idx].stop()
            print("Turbine " .. idx .. " stopped.")
          else
            print("Invalid turbine index or use 'all'")
          end

        elseif (keywords[1] == "startup") then
          activation = true
          print("ESBSR system enabled.")

        elseif (keywords[1] == "shutdown") then
          activation = false
          print("ESBSR system disabled.")

        elseif (keywords[1] == "exit") then
          stop_all(turbines)
          print("All turbines stopped. Exiting.")
          os.exit()

        elseif (keywords[1] == "help") then
          print("'get esbsr' -> Show ESBSR activation state, thresholds, and turbine auto modes.")
          print("'get turbine [n/all]' -> Show turbine status")
          print("'set min/max/throttle/auto ...' -> Configure system")
          print("'start/stop [n/all]' -> Control turbines")
          print("'startup/shutdown' -> Toggle ESBSR automation")
          print("'exit' -> Exit and shutdown turbines")
          print("'help' -> Show help message")

        else
          print("Unknown command. Try 'help' for help.")
        end
      end
    end
  end

  term.setCursor(1, 3)
  io.write("> " .. input)
  screen_divider(" ")

  for i, t in ipairs(turbines) do
    t.setAuto(auto[i])
  end

  if math.abs(time("%M") - temp[1]) >= 1 then
    term.setCursor(1, 1)
    local energy_now = battery_present and battery_energy[1] or 0
    local energy_max = battery_present and battery_energy[2] or 1

    print(string.format(
      "Heartbeat: %s | Battery: %s / %s HE (%.1f%%) | ESBSR: %s | Max: %.1f%% | Min: %.1f%%",
      blink and "*" or " ",
      x3_scale(energy_now), x3_scale(energy_max),
      battery_percentage * 100,
      activation and "ON" or "OFF",
      max * 100, min * 100
    ))

    screen_divider("=")
    term.setCursor(1, 4)
    screen_divider("=")

    if not battery_present then
      gpu.setForeground(0xFFE600)
      print("Warning: Energy Storage Block missing. Grid setups will be ignored.")
      gpu.setForeground(0xFFFFFF)
    end

    print("Turbine Status:")
    for i, t in ipairs(turbines) do
      local s = ({[-1]="Starting...", [0]="Offline", [1]="Online"})[t.getState()] or "Error"
      print(string.format("  Turbine %d: Status: %-10s | Throttle: %3d%% | Power: %s HE", i, s, t.getThrottle(), x3_scale(t.getPower())))
    end

    screen_divider("-")
    x, y = term.getCursor()
    temp[1] = time("%M")
    blink = not blink
  end
end

term.clear()
print("Exited cleanly. ESBSR system shutdown.")
return
