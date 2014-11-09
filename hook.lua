local hook = {}


hook.irc = nil

local hooks = {}

local function handleCommands(user, channel, message)

  if not message:sub(1,1) == ":" then
    return
  end
  
  local message = message:sub(2)
  cmd = message:gsub(" .+$", "")
  print(message, cmd)
  if hooks["command_"..cmd] then
    local res = hooks["command_"..cmd].handler(message:gsub(cmd.." ",""),user, channel)
    if res ~= nil then
      hook.irc:sendChat(channel, user.nick..", ".. tostring(res))
    end
  end
  
end


local function chatHook(user, channel, message)
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



return hook


