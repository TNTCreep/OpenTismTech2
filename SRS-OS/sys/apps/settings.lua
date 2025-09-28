-- TherOS system settings

print("loading...")

local configfile = io.open("/sys/.config/general.tc", "w")

local fs = require("filesystem")
local th = require("theros")
local conf = require("conlib")
local t = require("term")
local gpu = require("component").gpu
local ct = require("centertext")
local e = require("event")
local w, h = gpu.getResolution()

local bkgclr, txtclr, usoclr, sloclr, fmdclr, fmfclr, appdir, trmdir, editor = conf.general()
local sysver, _, _, _, configver = conf.version()
gpu.setBackground(bkgclr)
t.clear()
_, _, _, yopt = e.pull("touch")
local function general()
  gpu.fill(2,2,w-1,h-1," ")
  
end

local function about() -- gather system info and os version

end

while true do
  th.dwindow(1, 1, w, h, "Settings")
  ct(3, "System settings")
  options = {"General", "About & version"}
  for i, option in ipairs(options) do
    ct((i / 2) + 3, option)
  end
  choice = 4 + (yopt / 2)
  if choice == 1 then
    general()
  elseif choice == 2 then
    about()
  end
end
