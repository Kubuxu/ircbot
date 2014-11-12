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
  
  local ok, result =  pcall(sandbox(message,{["env"] = env}))
  
  if not ok then
    return result
  elseif type(result)=="function"then
    local res = ""
    for v in result do
      res = res .. tostring(v) .. ", "
      if res:len() > 1024 then
        return res .. "..."
      end
    end
    return res:sub(1,-2)
  end
  
  return result
end

hook.new("command_>", handle)
