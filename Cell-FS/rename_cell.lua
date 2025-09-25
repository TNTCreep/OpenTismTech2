local component = require("component")
local term = require("term")
local filesystem = require("filesystem")
local gpu = component.gpu

gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.copy(1, 2, w, h - 1, 0, -1)
gpu.fill(1, h, w, 1, " ")
term.setCursor(1, h)
term.write("Name? ")
filesystem.rename(selectedFile, filesystem.canonical(selectedFile .. "/..") .. "/" .. string.gsub(term.read(), "\n", ""))