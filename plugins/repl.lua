local hook = require "hook"

local sandbox = require "sandbox"

local envs = {}

local function handle(message, user, channel)
  
  if not hook.auth(user) then
    return "Nope"
  end
  local env = envs[user.nick]
  
  if env == nil then
    env = {}
    envs[user.nick] = env
    setmetatable(env, {["__mode"] = "k"})
  end


  local message = message:gsub("^%s*=", "return ") 
  
  local  result = table.pack(pcall(sandbox(message,{["env"] = env})))
  
  if not result[1] then
    return result[2]
  elseif type(result[2])=="function"then
    local res = ""
    for v in result[2] do
      res = res .. tostring(v) .. ", "
      if res:len() > 1024 then
        return res .. "..."
      end
    end
    return res:sub(1,-3)
  end
  
  return table.unpack(result)
end

hook.new("command_>", handle)
