local args = {...}

local oldpath = package.path

package.path = "./?/?.lua;./?/init.lua;" .. package.path
package.path = "./Vexatos-Programs/selene/lib/?.lua;./Vexatos-Programs/selene/lib/?/?.lua;./Vexatos-Programs/selene/lib/?/init.lua;" .. package.path
require "irc"

hook = require "hook"
serialization = require "serialization"

local sleep = require "socket".sleep

local c = irc.new{nick = "Entity"}

hook.setIRC(c)

pcall(require,"lfs") 
if not lfs then
  lfs = {}
  lfs.dir = function(path)
    local res = {}
    return io.popen("dir \"".. path .."\" /b /a"):lines()
  end
end

if not _G._selene then _G._selene = {} end
_G._selene.liveMode = false
require("selene")

local modsdir = "./plugins"
package.path = ("lualibs/?.lua;lualibs/?/?.lua;lualibs/?/init.lua;lualibs/?/?/?.lua;lualibs/?/?/init.lua;"):gsub("lualibs",modsdir) .. package.path
for mod in lfs.dir(modsdir) do
  mod = mod:gsub("%.lua$","")
  print(mod)
  print(pcall(require, mod))
  
end


c:connect("irc.esper.net")
if args[1] then
  c:sendChat("NickServ", "identify " .. args[1])
end
sleep(1)
c:join("#Starchasers")
c:join("#V")
c:join("#NovaAPI")
c:join("#computronics")
while true do
  c:think()
  sleep(0.5)
end
