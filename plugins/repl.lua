local hook = require "hook"

local sandbox = require "sandbox"

local envs = {}

local function handle(message, user, channel)
  
  if not hook.auth(user) then
    return "Nope"
  end
 
  envs[user.nick] = envs[user.nick] or {}
  local env = envs[user.nick]

  local message = message:gsub("^%s*=", "return ") 
  
  local ok, result =  pcall(sandbox(message,{[env] = env}))
  return result
end

hook.new("command_>", handle)