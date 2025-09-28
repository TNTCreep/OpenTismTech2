-- System manual for TherOS

print("-- MANUAL --")
io.write("1. Installing\n2. File manager\n3. TherTerm\n4. Where is everything???\n5. Bug reporting and feature suggestion\nType 'exit' to exit\n")
::uh::
io.write("-> ")
chs = io.read()
if chs == "1" then
  print("- INSTALLATION -")
  print("To install or update TherOS, run the installer program that comes packaged with TherOS and choose your desired version. The bleeding edge branch will always be the most up-to-date version, though it may be buggy. If you do not have access to the internet from your computer, and have a floppy with TherOS on it, you are gonna have to change the drive ID in the installer code.")
  print("Make sure to update the installer before updating your system.")
  print("- INSTALLATION -")
  goto uh
elseif chs == "2" then
  print("- FILE MANAGER -")
  print("TherOS has a built in file manager, and is named as such. This file manager can make/delete directories and make, move, copy, run, edit, or delete files.")
  print("To manage files, just click them and choose your desired action. To manage directories, shift-click them. To make new files/directories, click on the path at the top or in a blank space in the list of files.")
  print("../ will move you to the parent directory of the current directory (which is printed at the top). ./ will just keep you at the same directory.")
  print("The selected file will be printed at the top left when you select a file or directory.")
  print("- FILE MANAGER -")
  goto uh
elseif chs == "3" then
  print("- TherTerm -")
  print("TherTerm (short for TherOS Terminal) is a terminal app that allowes you to do things that are allowed by OpenOS but not possible with any apps in TherOS.")
  print("Cant do something? Try to do it through TherTerm.")
  print("- TherTerm -")
  goto uh
elseif chs == "4" then
  print("- Where is everything? -")
  print("All TherOS files, with the exeption of libraries (in /lib/) and the bootloader (/boot/94_therboot.lua), are located in /sys/.")
  print("The system environment is stored in /sys/env/, all apps you see on the main screen are in /sys/apps/ (configurable), and TherTerm is located in /sys/util/.")
  print("- Where is everything? -")
  goto uh
elseif chs == "5" then
  print("- Bug reporting and feature suggestion -")
  print("All bug reporting and feature suggestions should go in the \"issues\" tab in github. Note that i will not be able to fix everything immediately.")
  print("- Bug reporting and feature suggestion -")
  goto uh
elseif chs == "exit" then
  os.exit()
else
  print("Not a valid option!")
  goto uh
end
