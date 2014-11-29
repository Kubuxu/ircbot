local hook = require "hook"

hook.new("command_act", function(message, user, channel) hook.irc:sendAction(channel, message) end)

hook.new("command_say", function(message, user, channel) hook.irc:sendChat(channel, message) end)

hook.new({"command_source","command_souce"}, function(message, user, channel) return "https://github.com/Kubuxu/ircbot" end)

hook.new("command_join", function(message, user, channel) if not hook.auth(user.nick) then return "Nope" else hook.irc:join(message) end end)
hook.new("command_leave", function(message, user, channel) if not hook.auth(user.nick) then return "Nope" else hook.irc:part(message) end end)

local debug = nil
hook.new("command_debug", function(message, user, channel)
    if not hook.auth(user.nick) then
      return "Nope"
    elseif not debug then
      debug = hook.irc:hook("OnSend", function(msg)
          print("OnSend",msg)
        end)
    else
      hook.irc:unhook(debug)
      debug = nil
    end
  end)




