-- Copyright (C) 2015 Ivan Epifanov, Hearst Shkulev Media

local log           = ngx.log
local ERR           = ngx.ERR
local ngx_header    = ngx.header
local shared        = ngx.shared
local json          = require "cjson"
local ck            = require "resty.cookie"


-- explode(seperator, string)
function explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+1 -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end


local _M = {}

_M._VERSION = '0.01'


local mt = { __index = _M }

function _M.init(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    local _decoded = json.decode(content)
    -- phones
    local _ptable = {}
    for key,value in pairs(_decoded.uaMatch.phones) do
      table.insert(_ptable, value)
    end
    local _phones="("..table.concat(_ptable, "|")..")"
    shared.mobile:set("phones",_phones)

    -- tablets
    local _ttable = {}
    for key,value in pairs(_decoded.uaMatch.tablets) do
      table.insert(_ttable, value)
    end
    local _tablets="("..table.concat(_ttable, "|")..")"
    shared.mobile:set("tablets",_tablets)

    -- ua headers
    shared.mobile:set("uaheaders",string.lower(table.concat(_decoded.uaHttpHeaders,"|")))

    -- headers
    local _htable = {}

    for key,value in pairs(_decoded.headerMatch) do
      if value == json.null then
        shared.mobile:set("header:"..string.lower(key),"(.+)")
      else
        shared.mobile:set("header:"..string.lower(key),"("..table.concat(value.matches,"|")..")")
      end
      table.insert(_htable, string.lower(key))
    end
    shared.mobile:set("headers",table.concat(_htable, "|"))
end


function _M.detect(isatabletmobile, cookie)
  if cookie then
    local cookie, err = ck:new()
    if not cookie then
      log(ngx.ERR, err)
      return 0
    end

    -- get mobile cookie
    local field, err = cookie:get(cookie)
    if field then
      ngx.var.mobile_detected = "false"
      return field
    end
  end

  local mobile_device = 'false'

  -- check headers
  for key, value in pairs(explode("|",shared.mobile:get("headers"))) do
    if ngx.var[value] then
      local m, err = ngx.re.match( ngx.var[value], shared.mobile:get("header:"..value))
      if m then
        mobile_device = 'true'
      else
        if err then
          log(ngx.ERR, "error: ", err)
          return 0
        end
      end
    end
  end

  -- compose UA string
  local _uastr = ""
  for key, value in pairs(explode("|",shared.mobile:get("uaheaders"))) do
    if ngx.var[value] then
      _uastr=_uastr.." "..ngx.var[value]
    end
  end

  -- check against phones
  local m, err = ngx.re.match( _uastr, shared.mobile:get("phones"))
  if m then
    mobile_device = 'true'
  else
    if err then
      log(ngx.ERR, "error: ", err)
      return 0
    end
  end

  -- check against tablets
  local m, err = ngx.re.match( _uastr, shared.mobile:get("tablets"))
  if m then
    if istabletmobile then
      mobile_device = 'true'
    else
      mobile_device = 'false'
    end
  else
    if err then
      log(ngx.ERR, "error: ", err)
      return 0
    end
  end

  ngx.var.mobile_detected = "true"
  return mobile_device
end

return _M
