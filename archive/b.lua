package.path = package.path .. ";C:/Users/korde/scoop/apps/luarocks/current/rocks/share/lua/5.4/?.lua"

local pe = require("pe-parser")
local obj = pe.parse("C:/Users/korde/Home/Github/SandLua/a.exe")
obj:dump()