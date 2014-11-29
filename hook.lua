require "logging.file"
local hook = {}


hook.irc = nil
hook.log = logging.file("ircbot-%s.log", "%Y-%m-%d")
hook.log:setLevel(logging.INFO)
local hooks = {}


local function str(count, tab)
  local res = ""
  for i = 1, count do
    res = res .. tostring(tab[i]) .. " , "
  end
  return res:gsub(" , $","")
end

local function countVals(...)
  return select("#" , ...) - 1, table.pack(select(2, ...))
end


local function handleCommands(user, channel, message)

  if message:sub(1,1) ~= ":" then
    return
  end
  
  local message = message:sub(2)
  cmd = message:gsub(" .+$", "")
  if hooks["command_"..cmd] then
    local count, res = countVals(pcall(hooks["command_"..cmd].handler,message:gsub("^"..cmd.." *",""),user, channel))
    if count >= 1 then
      hook.irc:sendChat(channel, user.nick..", ".. str(count,res):gsub("[\n\r]+"," | "):gsub("  $",""))
    end
  end
  
end


local function chatHook(user, channel, message)
  hook.log:info(("%s %s: %s"):format(channel,("<%s>"):format(user.nick),message))
  if not channel.match("^#") then
    channel = user.nick
  end
  handleCommands(user, channel, message)
  
end



function hook.setIRC(irc1)
  hook.irc = irc1
  hook.irc:hook("OnChat", chatHook)
end


function hook.new(names, handler, accessLevel)
  names = type(names) == "table" and names or {names}
  for _, name in pairs(names) do
    hooks[name] = {handler = handler, accessLevel = accessLevel or 0}
  end
end

function hook.auth(user)
  user = type(user) == "string" and {["nick"] = user} or user
  return user.nick == "Kubuxu"
end


return hook


