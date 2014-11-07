require "irc"

API = require "API"

local sleep = require "socket".sleep

local c = irc.new{nick = "ThatBot"}

API.setIRC(c)

pcall(require,"lfs") 
if not lfs then
  lfs = {}
  lfs.dir = function(path)
    local res = {}
    return io.popen("dir \"".. path .."\" /b /a"):lines()
  end
end

local modsdir = "./mods"
package.path = ("lualibs/?.lua;lualibs/?/?.lua;lualibs/?/init.lua;lualibs/?/?/?.lua;lualibs/?/?/init.lua;"):gsub("lualibs",modsdir) .. package.path
for mod in lfs.dir("mods") do
  mod = mod:gsub("%.lua$","")
  print(mod)
  print(pcall(require, mod))
  
end


c:connect("irc.esper.net")
c:join("#Starchasers")

while true do
  c:think()
  sleep(0.5)
end
