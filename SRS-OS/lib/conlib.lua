-- conlib for SRS-OS
conlib = {}
configfile = io.open("/sys/.config/general.tc", "r")
fullfile = configfile:read("*a")
configfile:close()
general = {}
for line in fullfile:gmatch("[^\r\n]+") do
  table.insert(general, line)
end
for _, line in ipairs(general) do
  conlib.bkgclr = conlib.bkgclr or tonumber(line:match("Bck%-clr:(.+)"))
  conlib.txtclr = conlib.txtclr or tonumber(line:match("Txt%-clr:(.+)"))
  conlib.usoclr = conlib.usoclr or tonumber(line:match("Usl%-clr:(.+)"))
  conlib.sloclr = conlib.sloclr or tonumber(line:match("Sel%-clr:(.+)"))
  conlib.fmdclr = conlib.fmdclr or tonumber(line:match("Fmd%-clr:(.+)"))
  conlib.fmfclr = conlib.fmfclr or tonumber(line:match("Fmf%-clr:(.+)"))
  conlib.appdir = conlib.appdir or line:match("App%-dir:(.+)")
  conlib.trmdir = conlib.trmdir or line:match("Trm%-dir:(.+)")
  conlib.editor = conlib.editor or line:match("Edt%-dir:(.+)")
end

function conlib.general()
  return conlib.bkgclr, conlib.txtclr, conlib.usoclr, conlib.sloclr, conlib.fmdclr, conlib.fmfclr, conlib.appdir, conlib.trmdir, conlib.editor
end
configfile = io.open("/sys/.config/version.tc")
fullfile = configfile:read("*a")
configfile:close()
version = {}
for line in fullfile:gmatch("[^\r\n]+") do
  table.insert(version, line)
end

for _, line in ipairs(version) do
  conlib.sysver = conlib.sysver or line:match("System:(.+)")
  conlib.inver = conlib.inver or line:match("Instll:(.+)")
  conlib.fmver = conlib.fmver or line:match("Filemn:(.+)")
  conlib.ctlibver = conlib.ctlibver or line:match("Ctxlib:(.+)")
  conlib.configver = conlib.configver or line:match("Config:(.+)")
  conlib.theroslibver = conlib.theroslibver or line:match("ThOlib:(.+)")
  conlib.termver = conlib.termver or line:match("Termin:(.+)")
end

function conlib.version()
  return conlib.sysver, conlib.inver, conlib.fmver, conlib.ctlibver, conlib.configver, conlib.theroslibver, conlib.termver
end

return conlib

