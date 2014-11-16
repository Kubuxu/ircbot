local hook = require "hook"
local utils = require "utils"
local sandbox = require "sandbox"

envs = envs or {}

local function get(nick)
  if not envs[nick] then
    envs[nick] = {}
    if not hook.auth(nick) then
      setmetatable(envs[nick], {["__mode"] = "k"})
    end
  end
  envs[nick].nick = nick
  return envs[nick]
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
hook.new({"command_=","command_>="}, function(message,...) return handle("="..message,...) end)

local function steal(message, user, channel)
  local from = envs[message:gsub(" .+$", "")]
  if from == nil then
    return "Looks like the vault is empty."
  end
  
  local to = get(user.nick)
  local what = message:gsub("^[^ ]+ ", "")
  to[what] = utils.copy(from[what])
  if to[what] == nil then
    return "Looks like you stolen a whole nothing."
  else 
    return "Shhhhh."
  end
end

hook.new("command_steal", steal)

local function clear(message, user, channel)
  if not hook.auth(user) then
    return "Nope."
  end
  envs[message] = nil
  return "Cleared " .. message .. "'s ENV"
end

hook.new("command_clear", clear)

local function stash(message, user, channel)
  
  
end
hook.new("command_stash", stash)

local function unstash(message, user, channel)
  
  
end
hook.new("command_unstash", stash)