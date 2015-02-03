Name
====

lua-resty-mobile - This library parses HTTP headers and detects mobile devices

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Requirements](#requirements)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [new](#new)
    * [get](#get)
    * [get_all](#get_all)
    * [set](#set)
* [Installation](#installation)
* [Authors](#authors)
* [Copyright and License](#copyright-and-license)

Status
======

This library is production ready.

Requirements
======

This library requires [lua-resty-cookie](https://github.com/cloudflare/lua-resty-cookie) and cjson  
Also, this library uses definitions json file from (http://mobiledetect.net/)

Synopsis
========
```lua
    lua_package_path "/path/to/lua-resty-mobile/lib/?.lua;;";

    lua_shared_dict mobile 5m;

    init_by_lua '
      require("resty.mobile").init("/path/to/Mobile_Detect.json")
    ';


    server {
        location /test {
            set $mobile_detected 0;
            set $mobile_device 'false';

            set_by_lua $mobile_device '
              return require("resty.mobile").detect(false,"mobile")
            ';
        }
    }
```

Methods
=======

[Back to TOC](#table-of-contents)

init
---
`syntax: require("resty.mobile").init(path)`

Parses json definitions file and populates shared dict.

[Back to TOC](#table-of-contents)

detect
---
`syntax: require("resty.mobile").detect(istabletmobile, cookiename)`

Detects mobile device.  
Returns string 'true' or 'false'.  
Returns 0 (and logs error) on any error.  
If first parameter is true - tablet devices are treated as mobile devices, otherwise as desktop.  
If second parameter is ommited, library will parse headers every time.  
If second parameter is a string - cookie with this name will be checked, and, if exists, check will be skipped.  

This method also requires (and sets) nginx variable $mobile_detected,
which will be set to string 'true' if device was detected by regexps, and to 'false' otherwise.


[Back to TOC](#table-of-contents)

Installation
============

You need to compile [ngx_lua](https://github.com/chaoslawful/lua-nginx-module/tags) with your Nginx.

You need to configure
the [lua_package_path](https://github.com/chaoslawful/lua-nginx-module#lua_package_path) directive to
add the path of your `lua-resty-mobile` source tree to ngx_lua's Lua module search path, as in

    # nginx.conf
    http {
        lua_package_path "/path/to/lua-resty-mobile/lib/?.lua;;";
        ...
    }

[Back to TOC](#table-of-contents)

Authors
=======

Epifanov Ivan <isage.dna@gmail.com>, Hearst Shkulev Media

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2015, by Epifanov Ivan <isage.dna@gmail.com>, Hearst Shkulev Media

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

