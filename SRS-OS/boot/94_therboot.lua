local gpu = require("component").gpu
local w, h = gpu.getResolution()
local bkgclr = require("conlib").general()
gpu.setBackground(bkgclr)
gpu.fill(1, 1, w, h, " ")

local sysver = require("conlib").version()
require("centertext")(h/2, "Welcome to TherOS " .. sysver)
pcall(loadfile("/sys/env/main.lua")(loadfile))
