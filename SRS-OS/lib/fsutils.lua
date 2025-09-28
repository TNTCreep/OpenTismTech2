-- filesystem utils

local fs = require("filesystem")
local fsutil = {}
function fsutil.copydir(dir, dest)
  local files = fs.list(dir)
  fs.makeDirectory(dest)
  for file in files do
    if fs.isDirectory(file) then
      fs.list(file)
    end
    fs.copy(dir .. file, dest .. file)
  end
end

function fsutil.movedir(dir, dest)
  fsutil.copydir(dir, dest)
  if fs.exists(dest) then
    fsutil.removedir(dir)
  end
end
return fsutil