local hook = require "hook"

hook.new("command_act", function(message, user, channel) hook.irc:sendAction(channel, message) end)

hook.new("command_say", function(message, user, channel) hook.irc:sendChat(channel, message) end)
