local hook = require "hook"

local ENV_MATH = {}
for i, v in pairs(math) do
    ENV_MATH[i] = v
  end
for i, v in pairs(bit32) do
  ENV_MATH[i] = v
end

function getMathENV()
  local res = {}
  for i,v in pairs(ENV_MATH) do
    res[i]=v
  end
end

  

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
  x[1] = options.guess1 or 0.1
  x[2] = options.guess2 or 0.9
  
  local maxi = options.maxi or 200
  local i = 2
  while i < maxi and fun(x[i]) == fun(x[i]) and  fun(x[i]) ~= fun(x[i-1]) do
    i = i + 1
    x[i] = x[i-1] - fun(x[i-1]) * (x[i-1] - x[i-2]) / (fun(x[i-1]) - fun(x[i-2]))
    print(x[i],x[i-1],fun(x[i]),fun(x[i-1]))
  end
    print(x[i])
  if (fun(x[i]) ~= fun(x[i]) or i == maxi) and not options.force then
    return "I'am not complex enough."
  end
  if fun(x[i]) ~= 0 then
    return "There is no such number. Try do it by hand..."
  end
  
  return x[i]  
end


local function eval(data)
  local ENV_MATH = {}
  for i, v in pairs(math) do
    ENV_MATH[i] = v
  end
  for i, v in pairs(bit32) do
    ENV_MATH[i] = v
  end 
  
  
  local fun, valid = load(" return (".. data .. ") ",nil,"t",getMathENV())
  if not fun then
    return valid
  end
  local valid, fun = pcall(fun)
  return fun
end





local function parse(data)
  
  data = data:gsub("%Ax", function(cap) return cap:sub(1,1) .. "(x)" end)
  data = data:gsub("x%A", function(cap) return "(x)" .. cap:sub(2,2) end)
  data = data:gsub("%)%(",")*(")
  
  local ready, n = data:gsub("=(.-)$"," -(%1)")
  if n == 0 then
    return eval(ready)
  end
  local ENV_MATH = {}
  for i, v in pairs(math) do
    ENV_MATH[i] = v
  end
  print(ready)
  local fun, valid = load("return function(x) return (".. ready .. ") end",nil,"t",getMathENV())
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
   return parse(message)
 end
 
 hook.new("command_calc", handleCommand)
 
