local API = {}


API.irc = nil

local commands = {}

local function chatHook(user, channel, message)
 
  local cmd = message:gsub(" .+$", "")
   
  if commands[cmd] then
    commands[cmd].handler(message:gsub(cmd.." ",""),user,channel)
  end
end

function API.setIRC(irc1)
  API.irc = irc1
  API.irc:hook("OnChat", chatHook)
end


function API.registerCommand(command, handler, accessLevel)
  commands[command] = {handler = handler, accessLevel = accessLevel or 0}
end



return API


