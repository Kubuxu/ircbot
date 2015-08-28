local sandbox = {
  _VERSION      = "sandbox 0.5",
  _DESCRIPTION  = "A pure-lua solution for running untrusted Lua code.",
  _URL          = "https://github.com/kikito/sandbox.lua",
  _LICENSE      = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- The base environment is merged with the given env option (or an empty table, if no env provided)
--

local selene = require"selene"
local BASE_ENV = {}

-- List of non-safe packages/functions:
--
-- * string.rep: can be used to allocate millions of bytes in 1 operation
-- * {set|get}metatable: can be used to modify the metatable of global objects (strings, integers)
-- * collectgarbage: can affect performance of other systems
-- * dofile: can access the server filesystem
-- * _G: It has access to everything. It can be mocked to other things though.
-- * load{file|string}: All unsafe because they can grant acces to global env
-- * raw{get|set|equal}: Potentially unsafe
-- * module|require|module: Can modify the host settings
-- * string.dump: Can display confidential server info (implementation of functions)
-- * string.rep: Can allocate millions of bytes in one go
-- * math.randomseed: Can affect the host sytem
-- * io.*, os.*: Most stuff there is non-save


-- Safe packages/functions below

--coroutine.create coroutine.resume coroutine.running coroutine.status
--coroutine.wrap   coroutine.yield
([[

_VERSION assert error    ipairs   next pairs
select tonumber tostring type unpack


math.abs   math.acos math.asin  math.atan math.atan2 math.ceil
math.cos   math.cosh math.deg   math.exp  math.fmod  math.floor
math.frexp math.huge math.ldexp math.log  math.log10 math.max
math.min   math.modf math.pi    math.pow  math.rad   math.random
math.sin   math.sinh math.sqrt  math.tan  math.tanh

os.clock os.difftime os.time os.date

string.byte string.char  string.find  string.format string.gmatch
string.gsub string.len   string.lower string.match  string.reverse
string.sub  string.upper string.rep   string.slice

bit32

table


serialization

selene _selene


ltype checkType checkFunc parCount lpairs isList

string.foreach string.map string.filter string.drop string.dropwhile string.foldleft string.foldright string.split
string.take string.takewhile string.takeright string.dropright string.iter


]]):gsub('%S+', function(id)
  local module, method = id:match('([^%.]+)%.([^%.]+)')
  if module then
    BASE_ENV[module]         = BASE_ENV[module] or {}
    BASE_ENV[module][method] = _G[module][method]
  else
    BASE_ENV[id] = _G[id]
  end
end)


local function protect_module(module, module_name)
  return setmetatable({}, {
    __index = module,
    __newindex = function(_, attr_name, _)
      error('Can not modify ' .. module_name .. '.' .. attr_name .. '. Protected by the sandbox.')
    end
  })
end

('coroutine math os string table selene _selene serialization'):gsub('%S+', function(module_name)
  BASE_ENV[module_name] = protect_module(BASE_ENV[module_name], module_name)
end)

-- auxiliary functions/variables
--
local pack, unpack, error, pcall,xpcall = table.pack, table.unpack, error, pcall,xpcall
BASE_ENV.pcall = function(f, ...)
  local result = pack(pcall(f, ...))
  print(result[1], result[2])
  if (not result[1]) and result[2]:find("Quota exceeded:") then
    error(result[2],0)
  end
  return unpack(result)
end

BASE_ENV.xpcall = function(f, msgh, ...)
  return xpcall(f, function(msg)
    if msg:find("Quota exceeded:") then
      error(msg,0)
    end
    return msgh(msg)
  end, ...)
end


local function merge(dest, source)
  for k,v in pairs(source) do
    if dest[k] == nil then
      dest[k] = v
    end
  end
  return dest
end

local function sethook(f, key, quota)
  if type(debug) ~= 'table' or type(debug.sethook) ~= 'function' then return end
  debug.sethook(f, key, quota)
end

local function cleanup()
  sethook()
end

-- Public interface: sandbox.protect
function sandbox.protect(code, options)
  if type(code) ~= 'string' then return end
  
  options = options or {}
  
  local quota = false
  if options.quota ~= false then
    quota = options.quota or 500000
  end
  
  env = options.env or {}
  env._G = env._G or env
  env = merge(env, BASE_ENV)
  
  env.print = env.print or function(...)
    env.__toprint = env.__toprint or {}
    local args = table.pack(...)
    for x = 1, args.n do
      table.insert(env.__toprint, serialization.serialize(args[x]))
    end
  end
  
  local sucess, result = pcall(selene.parse, code)
  if not sucess then
    error("Selene couldn't parse: \"" .. code .. "\" because: " .. result)
  end
  code = result
  
  local f, message = load(code,nil,"t",env)
  
  if not f then
    return error("Function: \"" .. code:gsub("[\n\r]+"," ") .. "\" could not be loaded because: " .. message)
  end
  
  return function(...)

    if quota then
      local timeout = function()
        cleanup()
        error('Quota exceeded: ' .. tostring(quota))
      end
      sethook(timeout, "", quota)
    end

   local function handleres(...)
     cleanup()
     if not ... then error(select(2, ...), 0) end
     if env.__toprint ~= nil and type(env.__toprint) == "table" and #env.__toprint ~= 0 then
       local result = table.pack(table.unpack(env.__toprint))
       local args = table.pack(...)
       for x = 2, args.n do
         result[#result+1] = args[x]
       end
       result.n = result.n + args.n - 1
       env.__toprint = nil
       return table.unpack(result)
     else
       return select(2,...)
     end
   end
   
   return handleres(pcall(f, ...))
    
  end
end

-- Public interface: sandbox.run
function sandbox.run(f, options, ...)
  return sandbox.protect(f, options)(...)
end

-- make sandbox(f) == sandbox.protect(f)
setmetatable(sandbox, {__call = function(_,f,o) return sandbox.protect(f,o) end})

return sandbox
