require "irc"

local sleep = require "socket".sleep

local c = irc.new{nick = "ThatBot"}


c:connect("irc.esper.net")
c:join("#Starchasers")

while(true) do
  c:think()
  sleep(0.5)
end
