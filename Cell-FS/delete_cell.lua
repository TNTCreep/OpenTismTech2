local filesystem = require("filesystem")
local component = require("component")
local event = require("event")
local gpu = component.gpu

local w, h = gpu.getResolution()

gpu.setBackground(0xFF0000)
gpu.setForeground(0xFFFFFF)
gpu.fill(w / 4 + w / 8, h / 4 + h / 8, w / 4, h / 4, " ")
gpu.set(w / 2 - 11, h / 4 + h / 8 + 2, "Delete file/directory?")
gpu.set(w / 2 - 11, h / 2 + h / 16 - 2, "Yes                 No")

while true do
  local _, _, x, y = event.pull("touch")
  if x >= w / 2 - 11 and x <= w / 2 - 9 and y == math.floor(h / 2 + h / 16 - 2) then
    filesystem.remove(selectedFile)
    break
  else
    break
  end
end