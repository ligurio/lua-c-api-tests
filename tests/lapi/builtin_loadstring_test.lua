--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

PIL: "8 – Compilation, Execution, and Errors"
https://www.lua.org/pil/8.html

Maliciously crafted precompiled code can crash Lua,
https://www.lua.org/bugs.html#5.1.3-5

Maliciously crafted precompiled code can blow the C stack,
https://www.lua.org/bugs.html#5.1.3-6

Code validator may reject (maliciously crafted) correct code,
https://www.lua.org/bugs.html#5.1.3-7

Maliciously crafted precompiled code can inject invalid boolean
values into Lua code,
https://www.lua.org/bugs.html#5.1.3-8

Synopsis: loadstring(string [, chunkname])
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    -- LuaJIT ASSERT lj_bcread.c:123: bcread_byte: buffer read overflow
    local ascii_buf = string.gsub(buf, "[^%z\1-\127][\128-\255][\192-\255][\128-\191]", "")
    local ok, res = pcall(loadstring, ascii_buf)
    if ok then
        pcall(res)
    end
end

local args = {
    artifact_prefix = "builtin_loadstring_",
    only_ascii = 1,
}
luzer.Fuzz(TestOneInput, nil, args)
