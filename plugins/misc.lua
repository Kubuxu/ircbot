local hook = require "hook"

hook.new("command_act", function(message, user, channel) hook.irc:sendAction(channel, message) end)

hook.new("command_say", function(message, user, channel) hook.irc:sendChat(channel, message) end)

hook.new({"command_source","command_souce"}, function(message, user, channel) return "https://github.com/Kubuxu/ircbot" end)