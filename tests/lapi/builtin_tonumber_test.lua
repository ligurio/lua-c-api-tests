--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Fix binary number literal parsing,
https://www.freelists.org/post/luajit/Fractional-binary-number-literals
https://github.com/tarantool/luajit/commit/0ab421bc4077fa83039e653d4959fcdb2fa96ca6

tonumber produces wrong results for large exponents,
https://github.com/LuaJIT/LuaJIT/issues/788

tonumber("-0") returns 0, but it should be -0,
https://github.com/LuaJIT/LuaJIT/issues/528

 Fix conversion for strings with null char,
https://github.com/LuaJIT/LuaJIT/pull/558

Synopsis: tonumber(e [, base])
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

local MIN_BASE = 2
local MAX_BASE = 36

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local base = fdp:consume_integer(MIN_BASE, MAX_BASE)
    local max_len = fdp:consume_integer(0, MAX_INT)
    local e = fdp:consume_string(max_len)
    local num = tonumber(e, base)
    if num == nil then
        return
    end
end

local args = {
    artifact_prefix = "builtin_tonumber_",
}
luzer.Fuzz(TestOneInput, nil, args)
