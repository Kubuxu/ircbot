local hook = require "hook"

local sandbox = require "sandbox"

local envs = {}

local function handle(message, user, channel)
  
  if not hook.auth(user) then
    return "Nope"
  end
 
  local env = envs[user.nick] or {}
  hook.irc:sendChat(env.test)
  local message = message:gsub("^%s*=", "return ") 
  
  local ok, result =  pcall(sandbox(message,{[env] = env}))
  return result
end

hook.new("command_>", handle)