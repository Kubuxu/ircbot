local hook = require "hook"

local sandbox = require "sandbox"

envs = envs or {}

local function get(nick)
  if envs[nick] then
    return envs[nick]
  else
    envs[nick] = {}
    setmetatable(envs[nick], {["__mode"] = "k"})
    return envs[nick]
  end
end


local function handle(message, user, channel)
  if #(message:gsub("^%s","")) == 0 then 
    return
  end
  local message = message:gsub("^%s*=", "return ") 
  
  local env = get(user.nick)
  return select(2, pcall(sandbox(message,{["env"] = env})))
end

hook.new("command_>", handle)

local function steal(message, user, channel)
  local from = envs[message:gsub(" .+$", "")]
  if from == nil then
    return "Looks like the vault is empty."
  end
  
  local to = get(user.nick)
  local what = message:gsub("^[^ ]+ ", "")
  to[what] = from[what]
  if to[what] == nil then
    return "Looks like you stolen a whole nothing."
  else 
    return "Shhhhh."
  end
end

