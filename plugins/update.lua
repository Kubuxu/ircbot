local hook = require "hook"

local function build(build_fn, iterator_fn, state, ...)
    build_fn = (
            build_fn
        or  function(arg)
                return arg
            end
    )
    local res, res_i = {}, 1
    local vars = {...}
    while true do
        vars = {iterator_fn(state, vars[1])}
        if vars[1] == nil then break end
        --build_fn(unpack(vars)) -- see http://trac.caspring.org/wiki/LuaPerformance : TEST 3
        res[res_i] = build_fn(vars)
        res_i = res_i+1
    end
    return res
end

local function handleGit(message, user, channel)
  if message:find("^pull") then
    return table.concat(build(io.popen("git pull"):lines()), ", ")
  end
end
hook.new("command_git", handleGit)

local function reload(message, user, channel)
  local pack = message:match'^%s*(.*%S)'
  if not pack then
    return "You must specify package name"
  end
  local res = ""
  if package.loaded[pack] then
    res = res .. "Unloading " .. pack .. "\n"
    _ = type(package.loaded[pack]) == "table" and package.loaded[pack].uninit and package.loaded[pack].uninit()
  end
  res = res .. "Loading " .. pack .. "\n"
  local worked, message = pcall(require,pack)
  
  if not worked then
    res = res .. message
  end
  return res
end

hook.new("command_reload", reload)
  