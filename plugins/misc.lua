local hook = require "hook"

hook.new("command_act", function(message, user, channel) hook.irc:sendAction(channel, message) end)