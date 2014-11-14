local hook = require "hook"

local sandbox = require "sandbox"

local envs = {}

local function handle(message, user, channel)
  
  if #(messag:gsub("^%s","")) == 0 then 
    return
  end
  
  local env = envs[user.nick]
  
  if env == nil then
    env = {}
    envs[user.nick] = env
    setmetatable(env, {["__mode"] = "k"})
  end


  local message = message:gsub("^%s*=", "return ") 
  
  return select(2, pcall(sandbox(message,{["env"] = env})))
end

hook.new("command_>", handle)
