local hook = require "hook"

local function build(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

local function handleGit(message, user, channel)
  if not hook.auth(user) then
    return "Nope"
  end
  if message:find("^pull") then
    return table.concat(build(io.popen("git pull && git submodule init && git submodule foreach git pull && git submodule status"):lines()), ", ")
  end
end
hook.new("command_git", handleGit)

local function reload(message, user, channel)
  
  if not hook.auth(user) then
    return "Nope"
  end 
  
  local pack = message:match'^%s*(.*%S)'
  if not pack then
    return "You must specify package name"
  end
  local res = ""
  if package.loaded[pack] then
    res = res .. "Unloading " .. pack .. "\n"
    _ = type(package.loaded[pack]) == "table" and package.loaded[pack].unload and package.loaded[pack].unload()
    package.loaded[pack] = nil
  end
  res = res .. "Loading " .. pack .. "\n"
  local worked, message = pcall(require,pack)
  
  if not worked then
    res = res .. message
  end
  res = res .. "Loaded " .. pack .. "\n"
  return res
end

hook.new("command_reload", reload)

hook.new("command_unsafestop", function(message, user, channel)
    if not hook.auth(user) then
      return "Nope"
    end
    os.exit()
  end)

hook.new("command_restart", function(message, user, channel)
  if not hook.auth(user) then
    return "Nope"
  end
  io.popen("sleep 3 && ./start.sh")
  hook.irc:disconnect()
  os.exit()
  end)
  