--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Revert to trival pow() optimizations to prevent inaccuracies,
https://github.com/LuaJIT/LuaJIT/commit/96d6d503

Optimizations for power operator a^b,
https://github.com/LuaJIT/LuaJIT/issues/9

Fix pow() optimization inconsistencies,
https://github.com/LuaJIT/LuaJIT/commit/9512d5c1

Synopsis: math.pow(x, y)
]]

local luzer = require("luzer")
local test_lib = require("lib")

if test_lib.lua_version() ~= "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local y = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local res = math.pow(x, y)
    assert(type(res) == "number")
end

local args = {
    artifact_prefix = "math_pow_",
}
luzer.Fuzz(TestOneInput, nil, args)
