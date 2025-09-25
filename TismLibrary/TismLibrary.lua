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
-- write here stupid stinky head
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
  print("\nInstallation complete. Consider checking out the github at https://github.com/TNTCreep/OpenTismTech2")
else
  print("\nInvalid selection. Please run the installer again and choose a valid option.")
end
