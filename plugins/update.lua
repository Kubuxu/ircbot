local hook = require "hook"

local function build(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
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
    package.loaded[pack] = nil
  end
  res = res .. "Loading " .. pack .. "\n"
  local worked, message = pcall(require,pack)
  
  if not worked then
    res = res .. message
  end
  return res
end

hook.new("command_reload", reload)

hook.new("command_unsafestop", function() os.exit() end)

hook.new("command_restart", function() io.popen("sleep 3 && ./start.sh") hook.irc:disconnect() os.exit() end)
  