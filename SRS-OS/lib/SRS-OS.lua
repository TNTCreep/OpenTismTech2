-- SRS-OS general lib
local fs = require("filesystem")
local gpu = require("component").gpu
local w, h = gpu.getResolution()
local ct = require("centertext")
local t = require("term")
local e = require("event")

local theros = {}

function theros.run(program)
  if not fs.exists(program) then
    return false, "FILE NOT FOUND (Does the file exist?)"
  end
  local prgm = ""
  local file, reason = io.open(program, "r")
  if not file then
    return false, "ERR: " .. reason
  end
  repeat
    local chunk = file:read(math.huge)
    if chunk then
      prgm = prgm .. chunk
    end
  until not chunk
  file:close()

  local func, reason = load(prgm, "=" .. program)
  if not func then
    return false, "LDERR: " .. reason
  end

  local success, result = pcall(func)
  if not success then
    return false, "EXECERR: " .. result
  end
  return result
end

function theros.dwindow(x, y, w, h, titletext)
  gpu.fill(x,y,w,1,"═") -- top
  gpu.fill(x,y+h-1,w,h,"═") -- bottom
  gpu.fill(x,y,1,h,"║") -- left
  gpu.fill(x+w-1,1,w,h,"║") -- right
  gpu.set(x,y,"╔") -- top left corner
  gpu.set(x+w-1,y,"╗") -- top right corner
  gpu.set(x,y+h-1,"╚") -- bottom left corner
  gpu.set(x+w-1,y+h-1,"╝") -- bottom right corner

  gpu.set(math.floor(w/2)-math.floor(#titletext/2), 1, "[" .. titletext .. "]") -- setting the top text at the middle of the top
  --gpu.setForeground(0xFF0000) --red
  --gpu.set(w-4,1,"[X]") -- close button
  --local _, x, y, _, _ = e.pull("touch") -- grabbing touch signal
  --if x == w-4 and y == 1 then -- do the exit thingy
    --os.exit()
  --end
  return {x = x, y = y, w = w, h = h}
end

function theros.clamp(value, min, max)
  if value < min then
    return max
  elseif value > max then
    return max
  else
    return value
  end
end

function theros.popup(header, type, text)
  header = "-----" .. header .. "-----"
  gpu.fill((w/2)-(#header/2), (h/2)-2, (w/2)+(#header/2),(h/2)+1, " ")
  if type == "err" then
    if text ~= nil then
      ct((h/2)-2, header)
      ct((h/2)-1, text)
      ct(h/2, "Press ENTER to close")
      ct((h/2)+1, string.rep("-", #header))
      _ = io.read()
    end
  elseif type == "input" then
    ct((h/2)-2, header)
    ct((h/2)-1, text)
    t.setCursor((w/2)-(#header - #header), h/2)
    ct((h/2)+1, string.rep("-", #header))
    input = io.read()
    return input
  elseif type == "stdout" then
    ct((h/2)-1, header)
    ct(h/2, text)
    ct((h/2)+1, string.rep("-", #header))
  else
    ct((h/2)-1, "-----POPUP NOT SET UP PROPERLY!-----")
    ct(h/2, "Missing or incorrect 'type' for popup.")
    ct((h/2)+1, string.rep("-", #"-----POPUP NOT SET UP PROPERLY!-----"))
  end
end

return theros
