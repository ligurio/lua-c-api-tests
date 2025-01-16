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
    -- The natural logarithm (base e) of x. If x is ±0,
    -- returns -Infinity. If x < 0, returns NaN.
    local x = fdp:consume_number(0, test_lib.MAX_INT)
    local y = fdp:consume_number(0, test_lib.MAX_INT)
    local b = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    if b < 0 or b == 1 then return -1 end

    -- Product rule.
    assert(test_lib.approx_equal(math.log(x * y, b),
                                 math.log(x, b) + math.log(y, b), 0.01))
    -- Quotient rule.
    -- FIXME: assert(test_lib.approx_equal(math.log(x / y, b), math.log(x, b) - math.log(y, b), 0.5))

    if test_lib.lua_version() == "LuaJIT" then
        -- Power rule.
        assert(test_lib.approx_equal(math.log(math.pow(x, y), b), y * math.log(x, b), 0.01))
        -- Inverse property of logarithm.
        assert(test_lib.approx_equal(math.log(math.pow(b, x), b), x, 0.01))
        -- Inverse property of exponent.
        assert(test_lib.approx_equal(math.pow(b, math.log(x, b)), x, 0.01))
    end
    -- Zero rule.
    assert(math.log(1, b) == 0)
    -- Identity rule.
    assert(test_lib.approx_equal(math.log(b, b), 1, 0.1))
    -- Change of base formula.
    local log_b_y = math.log(b, y)
    if log_b_y ~= 0 then
        assert(test_lib.approx_equal(math.log(x, b), math.log(x, y) / log_b_y, 0.01))
    end
end

local args = {
    artifact_prefix = "math_log_",
}
luzer.Fuzz(TestOneInput, nil, args)
