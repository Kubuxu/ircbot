require "logging.file"
local hook = {}


hook.irc = nil
hook.log = logging.file("ircbot-%s.log", "%Y-%m-%d")
hook.log:setLevel(logging.INFO)
local hooks = {}


local function str(tab)
  local res = ""
  tab[1] = tab[1]==nil and "nil" or "false"
  for i, v in ipairs(tab) do
    res = res .. tostring(v) .. "  "
  end
  return res:gsub("  $","")
end

local function handleCommands(user, channel, message)

  if message:sub(1,1) ~= ":" then
    return
  end
  
  local message = message:sub(2)
  cmd = message:gsub(" .+$", "")
  if hooks["command_"..cmd] then
    local _ res = table.pack(pcall(hooks["command_"..cmd].handler,message:gsub(cmd.." ",""),user, channel))
    if select("#", res) >= 0 then
      hook.irc:sendChat(channel, user.nick..", ".. str(res):gsub("[\n\r]+"," | "):gsub("  $",""))
    end
  end
  
end


local function chatHook(user, channel, message)
  hook.log:info(("%s %s: %s"):format(channel,("<%s>"):format(user.nick),message))
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
  

  if false and (user.access.op == nil) then
    hook.irc:whois(user.nick)
  end
  --print(user.access.op, user.access.halfop)
 return true --(user.access.op or user.access.halfop)
end


return hook


