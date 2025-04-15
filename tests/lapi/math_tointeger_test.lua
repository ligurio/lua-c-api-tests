--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Synopsis: math.tointeger(x)
]]

local luzer = require("luzer")
local test_lib = require("lib")

if test_lib.lua_version() == "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local max_len = fdp:consume_integer(0, test_lib.MAX_INT)
    local x = fdp:consume_string(max_len)
    local res = math.tointeger(x)
    assert(type(res) == "number" or
           res == "fail" or
           res == nil)
end

local args = {
    artifact_prefix = "math_tointeger_",
}
luzer.Fuzz(TestOneInput, nil, args)
