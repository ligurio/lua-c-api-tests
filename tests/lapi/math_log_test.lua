--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Two-parameter logarithm gives incorrect answers for matching inputs,
https://github.com/LuaJIT/LuaJIT/issues/1240

Synopsis: math.log(x [, b])
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local y = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local b = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    if b < 0 or b == 1 then return -1 end

    -- Product rule.
    -- FIXME: assert(math.log(x * y, b) == math.log(x, b) + math.log(y, b))
    -- Quotient rule.
    -- FIXME: assert(math.log(x / y, b) == math.log(x, b) - math.log(y, b))
    if test_lib.lua_version() == "LuaJIT" then
        -- Power rule.
        -- FIXME: assert(math.log(math.pow(x, y), b) == y * math.log(x, b))
        -- Inverse property of logarithm.
        -- FIXMEL assert(math.log(math.pow(b, x), b) == x)
        -- Inverse property of exponent.
        -- FIXME: assert(math.pow(b, math.log(x, b)) == x)
    end
    -- Zero rule.
    assert(math.log(1, b) == 0)
    -- Identity rule.
    -- FIXME: assert(math.log(b, b) == 1)
    -- Change of base formula.
    -- FIXME: assert(math.log(x, b) == math.log(x, y) / math.log(b, y))
end

local args = {
    artifact_prefix = "math_log_",
}
luzer.Fuzz(TestOneInput, nil, args)
