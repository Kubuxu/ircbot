local hook = require "hook"

local sandbox = require "sandbox"

local envs = {}

local function input(message, user, channel)
  if not hook.auth(user) then
    return "Nope"
  end
  
  local env = envs[user.nick] or {}
  
  local message = message:gsum("^=", "return ") 
  
  local ok, result =  pcall(sandbox(message))
  return result
end

hook:new("command_>", input)