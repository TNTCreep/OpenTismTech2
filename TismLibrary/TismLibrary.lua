-- term
local term = require("term")

-- clears screen
term.clear()
term.setCursor(1, 1)

-- header
print("████████╗██╗░██████╗███╗░░░███╗  ██╗░░░░░██╗██████╗░██████╗░░█████╗░██████╗░██╗░░░██╗")
print("╚══██╔══╝██║██╔════╝████╗░████║  ██║░░░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝")
print("░░░██║░░░██║╚█████╗░██╔████╔██║  ██║░░░░░██║██████╦╝██████╔╝███████║██████╔╝░╚████╔╝░")
print("░░░██║░░░██║░╚═══██╗██║╚██╔╝██║  ██║░░░░░██║██╔══██╗██╔══██╗██╔══██║██╔══██╗░░╚██╔╝░░")
print("░░░██║░░░██║██████╔╝██║░╚═╝░██║  ███████╗██║██████╦╝██║░░██║██║░░██║██║░░██║░░░██║░░░")
print("░░░╚═╝░░░╚═╝╚═════╝░╚═╝░░░░░╚═╝  ╚══════╝╚═╝╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░")
print("\nPlease select which program you wish to install:\n")

-- programs
local programs = {
  {name = "AE2SCCPU-Wip", install = "wget 'https://example.com/program1.lua' 'program1.lua'"},
  {name = "Cell-FS-Snow", install = "wget https://raw.githubusercontent.com/TNTCreep/OpenTismTech1/refs/heads/main/Cell-FS/installer.lua installer.lua installer.lua'"},
  {name = "Cell-FS-Graphite", install = "wget https://raw.githubusercontent.com/TNTCreep/OpenTismTech1/refs/heads/main/Cell-FS/colouredmod/installergraphite.lua installergraphite.lua installergraphite.lua'"},
  {name = "Cell-FS-Scorched", install = "wget https://raw.githubusercontent.com/TNTCreep/OpenTismTech1/refs/heads/main/Cell-FS/colouredmod/installerscorched.lua installerscorched.lua installerscorched.lua'"},
  {name = "OpenRBMK-EarlyAlpha", install = "wget 'https://example.com/program5.lua' 'program5.lua'"},
  {name = "MotionSensor", install = "pastebin get JRSu4buv MotionSens"},
  {name = "SecuCODEX+-WIP", install = "wget 'https://example.com/program7.lua' 'program7.lua'"},
  {name = "SecuROM+-WIP", install = "wget 'https://example.com/program8.lua' 'program8.lua'"},
  {name = "TismLibrary", install = "wget 'https://example.com/program9.lua' 'program9.lua'"}
}

-- display
for i, prog in ipairs(programs) do
  print(string.format("(%d) - %s", i, prog.name))
end

-- prompt
io.write("\nEnter the number of the program to install: ")
local choice = tonumber(io.read())

-- validate choice
if choice and programs[choice] then
  local selected = programs[choice]
  print(string.format("\nInstalling %s...\n", selected.name))
  os.execute(selected.install)
  print("\nInstallation complete. Consider checking out the github at https://github.com/TNTCreep/OpenTismTech1")
else
  print("\nInvalid selection. Please run the installer again and choose a valid option.")
end
