local component = require("component")
local filesystem = require("filesystem")
local event = require("event")
local computer = require("computer")
local shell = require("shell")
local process = require("process")
local term = require("term")
local gpu = component.gpu
w, h = gpu.maxResolution()
local running = true
currentPath = "//"
local dirContents
local arrayContents
local currentFileBrowserPage = 1
selectedFile = "//init.lua"
local cellLocation
local i
local j
local tempchar
local loc
local fileOptions
clipboard = "//init.lua"

w = math.floor(w / 2) * 2
h = math.floor(h / 2) * 2
print(w, h)
gpu.setResolution(w, h)

function convArray(...)
  local array = {}
  for v in ... do
    array[#array + 1] = v
  end
  return array
end

function tableContains(table, element)
  local value
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function createProgramList()
  cellLocation = shell.resolve(process.info().path)
  cellLocation = filesystem.canonical(cellLocation .. "/..")
  shell.setPath(shell.getPath() .. "%:" .. cellLocation)
  print(cellLocation .. "/programs.cfg")
  local f = io.open(cellLocation .. "/programs.cfg")
  programs = {}
  i = 1
  while 1 do
    print("Loading program #" .. tostring(i) .. "...")
    programs[i] = {}
    print("Loading name...")
    while 1 do
      tempchar = f:read(1)
      if tempchar == ";" then
        break
      elseif programs[i][1] ~= nil then
        programs[i][1] = programs[i][1] .. tempchar
      else
        programs[i][1] = tempchar
      end
    end
    print("  Loading option name...")
    while 1 do
      tempchar = f:read(1)
      if tempchar == ";" then
        break
      elseif programs[i][2] ~= nil then
        programs[i][2] = programs[i][2] .. tempchar
      else
        programs[i][2] = tempchar
      end
    end
    programs[i][3] = {}
    j = 1
    print("  Loading file associations...")
    while 1 do
      tempchar = f:read(1)
      if tempchar == "," then
        j = j + 1
      elseif tempchar == ";" then
        break
      elseif programs[i][3][j] ~= nil then
        programs[i][3][j] = programs[i][3][j] .. tempchar
      else
        programs[i][3][j] = tempchar
      end
    end
    print("  Loading run syntax...")
    while 1 do
      tempchar = f:read(1)
      if tempchar == ";" then
        break
      elseif programs[i][4] ~= nil then
        programs[i][4] = programs[i][4] .. tempchar
      else
        programs[i][4] = tempchar
      end
    end
    programs[i][5] = {}
    j = 1
    print("  Loading additional options...")
    while 1 do
      tempchar = f:read(1)
      if tempchar == "," then
      j = j + 1
      elseif tempchar == nil or tempchar == "\n" then
        break
      elseif programs[i][5][j] ~= nil then
        programs[i][5][j] = programs[i][5][j] .. tempchar
      else
        programs[i][5][j] = tempchar
      end
    end
    if tempchar == nil then
      break
    end
    i = i + 1
  end
  f:close()
  os.sleep(0.5)
end

function clearBackground()
  gpu.setBackground(0xFFFFFF)
  gpu.setForeground(0x00DD44)
  gpu.fill(1, 1, w, h, " ")
end

function topBar()
  gpu.setBackground(0xDDDDDD)
  gpu.setForeground(0x00DD44)
  gpu.fill(1, 1, w, 1, " ")
  gpu.set(2, 1, "Cell-FS Beta")
  gpu.set(w - 3, 1, "Exit")
end

function divider()
  gpu.setBackground(0x808080)
  gpu.fill(w / 2, 2, 2, h, " ")
  gpu.fill(1, h / 2, w / 2, 2, " ")
end

function fileBrowser(page)
  gpu.setBackground(0xFFFFFF)
  gpu.fill(w / 2 + 2, 2, w / 2 - 2, h - 1, " ")
  gpu.setBackground(0xBBBBBB)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(w / 2 + 2, 2, w / 2 - 1, 2, " ")
  gpu.set(w / 2 + 3, 2, currentPath)
  gpu.setBackground(0x00FF00)
  gpu.setForeground(0xFFFFFF)
  gpu.set(w / 2 + 2, 3, "<--")
  gpu.set(w - 2, 3, "-->")
  gpu.setBackground(0x00DD00)
  gpu.set(w / 2 + 5, 3, " ↑ ")
  gpu.setBackground(0xFFFFFF)
  gpu.setForeground(0x00DD44)
  dirContents = nil
  arrayContents = nil
  dirContents = filesystem.list(currentPath)
  arrayContents = convArray(dirContents)
  for i, item in ipairs(arrayContents) do
    if i <= page * (h - 3) and i >= ((h - 3) * (page - 1)) + 1 then
      if currentPath .. item == selectedFile then
        gpu.setBackground(0x0000FF)
        gpu.setForeground(0xFFFFFF)
      end
      gpu.set(w / 2 + 2, (i - ((h - 3) * (page - 1))) + 3, item)
      gpu.setBackground(0xFFFFFF)
      gpu.setForeground(0x00DD44)
    end
  end
end

function functionsList()
  gpu.setBackground(0xFFFFFF)
  gpu.fill(1, 2, w / 2 - 1, h / 2 - 2, " ")
  gpu.setBackground(0xBBBBBB)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 2, w / 2 - 1, 1, " ")
  gpu.set(2, 2, "Functions")
  gpu.setBackground(0xFFFFFF)
  gpu.setForeground(0x00DD44)
  gpu.set(1, 3, "New File...")
  gpu.set(1, 4, "New Directory...")
  gpu.set(1, 5, "Paste...")
end

function optionsList()
  fileOptions = {}
  gpu.setBackground(0xFFFFFF)
  gpu.fill(1, h / 2 + 2, w / 2 - 1, h / 2 - 2, " ")
  gpu.setBackground(0xBBBBBB)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, h / 2 + 2, w / 2 - 1, 2, " ")
  gpu.set(2, h / 2 + 2, "Options")
  gpu.set(2, h / 2 + 3, selectedFile)
  gpu.setBackground(0xFFFFFF)
  gpu.setForeground(0x00DD44)
  loc = nil
  loc, _ = string.find(selectedFile, "%.")
  if loc == nil then
    loc = 0
  end
  j = 1
  for i, item in ipairs(programs) do
    if filesystem.isDirectory(selectedFile) then
      if tableContains(programs[i][3], "dir") then
        fileOptions[j] = programs[i]
        j = j + 1
      end
    else
      if tableContains(programs[i][3], string.sub(selectedFile, loc, string.len(selectedFile))) or tableContains(programs[i][3], "all") then
        --gpu.set(1, h / 2 + 3 + i, programs[i][2])
        fileOptions[j] = programs[i]
        j = j + 1
      end
    end
  end
  for i, item in ipairs(fileOptions) do
    gpu.set(1, h / 2 + 3 + i, fileOptions[i][2])
  end
end

function renderScreen()
  clearBackground()
  topBar()
  divider()
  fileBrowser(currentFileBrowserPage)
  functionsList()
  optionsList()
end

print("Starting Cell...")
createProgramList()
renderScreen()

while running do
  local _, _, x, y = event.pull("touch")
  if x >= w - 3 and x <= w and y == 1 then
    running = false
  end
  if x >= w / 2 + 2 and x <= w and y >= 4 and y <= h then
    if arrayContents[(y - 3) + ((h - 3) * (currentFileBrowserPage - 1))] == nil then
      computer.beep()
      --currentPath = filesystem.concat(currentPath, selectedFile) .. "/"
    else
      selectedFile = currentPath .. arrayContents[(y - 3) + ((h - 3) * (currentFileBrowserPage - 1))]
      fileBrowser(currentFileBrowserPage)
      optionsList()
      --gpu.setBackground(0x0000FF)
      --gpu.setForeground(0xFFFFFF)
      --shell.execute("edit " .. currentPath .. arrayContents[(y - 3) + ((h - 3) * (currentFileBrowserPage - 1))])
      --renderScreen()
    end
  end
  if x >= w / 2 + 5 and x <= w / 2 + 7 and y == 3 then
    currentPath = filesystem.concat(currentPath, "..") .. "/"
    currentFileBrowserPage = 1
    fileBrowser(currentFileBrowserPage)
  end
  if x >= w / 2 + 2 and x <= w / 2 + 4 and y == 3 then
    if currentFileBrowserPage > 1 then
      currentFileBrowserPage = currentFileBrowserPage - 1
      fileBrowser(currentFileBrowserPage)
    end
  end
  if x >= w - 2 and x <= w and y == 3 then
    currentFileBrowserPage = currentFileBrowserPage + 1
    fileBrowser(currentFileBrowserPage)
  end
  if x < w / 2 and y >= h / 2 + 4 then
    command = string.gsub(fileOptions[y - (h / 2 + 3)][4],"%?file%?", selectedFile)
    if tableContains(fileOptions[y - (h / 2 + 3)][5], "s") == false then
      gpu.setBackground(0x000000)
      gpu.setForeground(0xFFFFFF)
      gpu.fill(1, 1, w, h, " ")
      term.setCursor(1, 1)
    end
    shell.execute(command)
    os.sleep(0.05)
    renderScreen()
    --gpu.set(1, h, command)
  end
  if x < w / 2 and y >= 3 and y < h / 2 then
    if y == 3 then
      gpu.setBackground(0x000000)
      gpu.setForeground(0xFFFFFF)
      gpu.copy(1, 2, w, h - 1, 0, -1)
      gpu.fill(1, h, w, 1, " ")
      term.setCursor(1, h)
      term.write("File Name? ")
      io.open(currentPath .. string.gsub(term.read(), "\n", ""), "w")
      io.close()
      renderScreen()
    end
    if y == 4 then
      gpu.setBackground(0x000000)
      gpu.setForeground(0xFFFFFF)
      gpu.copy(1, 2, w, h - 1, 0, -1)
      gpu.fill(1, h, w, 1, " ")
      term.setCursor(1, h)
      term.write("Directory Name? ")
      filesystem.makeDirectory(currentPath .. string.gsub(term.read(), "\n", ""))
      renderScreen()
    end
    if y == 5 then
      shell.execute("cp " .. clipboard .. " " .. currentPath .. " -r")
      renderScreen()
    end
  end
end

gpu.setBackground(0x000000)
gpu.setForeground(0xFFFFFF)
gpu.fill(1, 1, w, h, " ")
