local hook = require "hook"

local ENV_MATH = {x = 0}
local underenv = {}
for i, v in pairs(math) do
    underenv[i] = v
  end
for i, v in pairs(bit32) do
  underenv[i] = v
end

local mathmeta = {
  
  __index = function(self, index)
    if underenv[index] then
      return underenv[index]
    end
    local number, newindex = index:gmatch("(%d+%.?%d*)(.+)")()
    number = tonumber(number)
    local value = underenv[newindex]
    if number == nil or value == nil then
      return nil;
    end
    if type(value) == "function" then
      return function(...) return number * value(...) end
    elseif tonumber(value) ~= nil then
      return number * tonumber(value) 
    end
    return nil
  end,
  __newindex = function() end
  
}

setmetatable(ENV_MATH,mathmeta)
  

local function solve(fun,options)
  
  local options = options or {}
  
  local cache = {}
  local fun = function (t)
    if cache[t] then
      return cache[t]
    else
      cache[t] = fun(t)
      return cache[t]
    end
  end
  
  
  local x = {}
  x[1] = options.guess1 or math.random()
  x[2] = options.guess2 or math.random()
  
  local maxi = options.maxi or 200
  local i = 2
  while i < maxi and fun(x[i]) == fun(x[i]) and  fun(x[i]) ~= fun(x[i-1]) do
    i = i + 1
    x[i] = x[i-1] - fun(x[i-1]) * (x[i-1] - x[i-2]) / (fun(x[i-1]) - fun(x[i-2]))
    print(x[i],x[i-1],fun(x[i]),fun(x[i-1]))
  end
    print(x[i])
    local fx = fun(x[i])
  if fx ~= fx or i == maxi or math.abs(fx) > (math.abs(fx) * 2^-50) and not options.force then
    return "I'am not complex enough. Try calculate it by hand..."
  end
  
  return x[i]  
end


local function eval(data)

  
  local fun, valid = load(" return (".. data .. ") ",nil,"t",ENV_MATH)
  if not fun then
    return valid
  end
  local valid, fun = pcall(fun)
  return fun
end





local function parse(data)
  data = data:gsub("%)%(",")*("):gsub("=+", "=")
  
  local ready, n = data:gsub("=(.-)$"," -(%1)")
  if n == 0 then
    return eval(ready)
  end
  local ENV_MATH = {}
  for i, v in pairs(math) do
    ENV_MATH[i] = v
  end
  print(ready)
  local fun, valid = load("return function(thisisuniqe) x = thisisuniqe return (".. ready .. ") end",nil,"t",ENV_MATH)
  if not fun then
    return valid
  end
  local valid, fun = pcall(fun)
  if not valid then
    return fun
  end
  local valid, result  = pcall(solve,fun)
  return result
end


 local function handleCommand(message, user,channel)
   return parse(message:gsub("function","NOPE"):gsub("repeat","NOPE"):gsub("while","NOPE"))
 end
 
 hook.new("command_calc", handleCommand)
 
