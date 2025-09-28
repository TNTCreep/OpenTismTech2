-- TherOS community repository package manager
list = io.open("/sys/.config/tocrlist.tc", "w")
local shell = require("shell")
local fs = require("filesystem")

local args, ops = shell.parse(...)

help = [[Usage:
-i, --install <pkg>    install a package and it's dependencies
-r, --remove <pkg>     remove a package
-u, --update           updates all installed packages.
-l, --list             pull and print list of all available packages
-a, --list-installed   print list of all installed packages
-h, --help             print help
-b, --build            build a package that isn't pre-built

You need an internet card to install packages. This will not pull files locally.]]
local deptab = {}
if ops.i or ops.install then
  for i, package in ipairs(args) do
    print("Installing " .. package)
    fs.makeDirectory("/usr/bin/")
    fs.makeDirectory("/usr/lib/")
    print("Checking for dependencies...")
    shell.execute("wget -q https://raw.githubusercontent.com/Tavyza/TherOS_community_repo/main/" .. package .. "/dependencies.tc /tmp/dependencies.tc")
    file = io.open("/tmp/dependencies.tc", "r")
    deps = file:read("*a")
    table.insert(deptab, deps)
    file:close()
    for _, dep in ipairs(deptab) do
      if dep ~= nil then
        print("-> installing " .. dep)
        local filename = dep:match("^.+/(.+)$")
        shell.execute("wget -q " .. dep .. " /usr/lib/" .. filename)
      else
        print("No dependencies.")
      end
    end
    print("Installing package " .. package .. "...")
    pkin = {}
    shell.execute("wget -q https://raw.githubusercontent.com/Tavyza/TherOS_community_repo/main/" .. package .. "/package.tc /tmp/package.tc")
    pk = io.open("/tmp/package.tc", "r")
    for pak in pk:gmatch("[^\r\n]+") do
      if pak ~= "" then
        table.insert(pkin, pak)
      end
    end
    for _, pak in ipairs(pkin)
      shell.execute("wget -q " .. pak)
    end
    fs.remove("/tmp/*")
  end
end

if ops.h or ops.help or not next(ops) then
  print(help)
end
list:close()