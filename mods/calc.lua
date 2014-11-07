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
  while i < maxi and fun(x[i]) ~= fun(x[i-1]) do
    i = i + 1
    x[i] = x[i-1] - fun(x[i-1]) * (x[i-1] - x[i-2]) / (fun(x[i-1]) - fun(x[i-2]))
    print(x[i],x[i-1],fun(x[i]),fun(x[i-1]))
  end
    print(x[i])
  if i == maxi and not options.force then
    error "I'am not complex enough."
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
  
  
  local fun, valid = load(" return (".. data .. ") ",nil,"t",ENV_MATH)
  if not fun then
    return valid
  end
  local valid, fun = pcall(fun)
  return fun
end





local function parse(data)
  local ready, n = data:gsub("=(.-)$"," -(%1)")
  if n == 0 then
    return eval(ready)
  end
  local ENV_MATH = {}
  for i, v in pairs(math) do
    ENV_MATH[i] = v
  end
  print(ready)
  local fun, valid = load("return function(x) return (".. ready .. ") end",nil,"t",ENV_MATH)
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
 
