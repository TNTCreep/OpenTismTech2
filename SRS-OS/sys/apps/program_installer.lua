print("loading...")

local t = require("term")
local ct = require("centertext")
local e = require("event")
local conf = require("conlib")
local th = require("theros")
local bkgclr, txtclr = conf.general()
local component = require("component")
gpu = component.gpu
local w, h = gpu.getResolution()
local fsu = require("fsutils")
local fs = require("filesystem")

t.clear()
gpu.setBackground(bkgclr)
gpu.setForeground(txtclr)
local function menu()
  local options = {"Install from Pastebin", "Install from other source", "Install from floppy"}
  t.clear()
  th.dwindow(1, 1, w, h, "TherOS app installer")
  for i, options in ipairs(options) do
    ct(5 + (i - 1) * 2, options, 0xFFFFFF)
  end
end

local function pastebin()
  local code = th.popup("Pastebin code", "input", "Enter pastebin code: ")
  local name = th.popup("File name", "input", "Enter desired file name: ")
  os.execute("pastebin get " .. code .. " " .. name)
  os.exit()
end
local function github()
  local link = th.popup("Link", "input", "Enter link: ")
  local gName = th.popup("File name", "input", "Enter desired file name: ")
  os.execute("wget " .. link .. " " .. gName)
  os.exit()
end

local function floppy()
  drives = component.list("filesystem")
  ct(2, "Select drive with program")
  for i, drive in ipairs(drives) do
    ct(3 + (i - 1), drive)
  end
  local _, _, _, y, _, _ = e.pull("touch")
  local selection = y - 3
  selectedDrive = drives[selection]
  for file in selectedDrive do
    if fs.isDirectory(file) then
      fsu.copydir(file, "/")
    else
      fs.copy(file, "/")
    end
  end
end

while true do
  menu()
  local _, _, _, y = e.pull("touch")
  local choice = math.floor((y - 5) / 2) + 1
  if choice == 1 then
    pastebin()
  elseif choice == 2 then
    github()
  elseif choice == 3 then
    floppy()
  end
  menu()
end