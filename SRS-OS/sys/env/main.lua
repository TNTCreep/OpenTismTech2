print("loading...")

local component = require("component")
local gpu = component.gpu
local c = require("computer")
local fs = require("filesystem")
local e = require("event")
local t = require("term")
local ct = require("centertext")
local conf = require("conlib")
local th = require("theros")
local shell = require("shell")

local bkgclr, txtclr, _, _, _, _, appdir, _, _ = conf.general()
local sysver = conf.version()

local w, h = gpu.getResolution()
gpu.fill(1, 1, w, h, " ")
gpu.setBackground(bkgclr)
local function updateOptions()
    local apps = {}
    for app in fs.list(appdir) do
        table.insert(apps, app:sub(1, -5))
        table.sort(apps)
    end
    return apps
end

local function displaySystemInfo()
    local uptimeMins = c.uptime() / 60 % 60
    local uptimeHour = (c.uptime() / 60) / 60
    local uptimesec = c.uptime() % 60
    uptime = c.uptime
    if c.uptime() > 60 then
        uptime = uptimeMins
        unit = "min"
    elseif c.uptime() > 3600 then
        uptime = uptimeHour
        unit = "hr"
    end
    local memCap = math.floor(c.totalMemory() / 1000)
    local memUsed = math.floor(memCap - (c.freeMemory() / 1000))
    ct(h - 3, "Uptime: " .. string.format("%02.0f", math.floor(uptimeHour)) .. ":" .. string.format("%02.0f", math.floor(uptimeMins)) .. ":" .. string.format("%02.0f", math.floor(uptimesec)))
    ct(h - 2, "Total RAM: " .. memCap .. " KB")
    ct(h - 1, "Used RAM: " .. memUsed .. " KB")
end

local function displayMenu(options, topText)
    t.clear()
    gpu.fill(1, 1, w, h, " ")
    ct(1, topText)
    displaySystemInfo()
    for i, option in ipairs(options) do
        ct(3 + (i - 1) * 2, option)
    end
end
local options = updateOptions()
table.insert(options, "reboot")
table.insert(options, "shutdown")
local topText = "TherOS " .. sysver

displayMenu(options, topText)

local lastAppUpdate = c.uptime()
local lastMemUpdate = c.uptime()

while true do
    local uptime = c.uptime()
    if uptime - lastAppUpdate >= 10 then
        options = updateOptions()
        table.insert(options, "reboot")
        table.insert(options, "shutdown")
        lastAppUpdate = uptime
        displayMenu(options, topText)
    end

    if uptime - lastMemUpdate >= 1 then
        displaySystemInfo()
        lastMemUpdate = uptime
    end

    local event = {e.pull(1)}
    if event[1] == "touch" then
        local _, _, x, y = table.unpack(event)
        local choice = math.floor((y - 3) / 2) + 1
        if choice >= 1 and choice <= #options then
            local selectedOption = options[choice]
            if selectedOption == "reboot" then
                c.shutdown(true)
            elseif selectedOption == "shutdown" then
                c.shutdown()
            else
                local good, err = shell.execute(fs.concat(appdir, selectedOption))
                if not good then
                    th.popup("Error!", "err", err)
                    os.sleep(2)
                end
                displayMenu(options, topText)
            end
        end
    end
end
