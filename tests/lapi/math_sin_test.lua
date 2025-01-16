--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Synopsis: math.sin(x)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local sin_x = math.sin(x)
    assert(type(sin_x) == "number")
    local cos_x = math.cos(x)
    assert(type(cos_x) == "number")

    -- cos² α + sin² α = 1
    assert(test_lib.approx_equal(cos_x^2 + sin_x^2, 1, 0.01))
end

local args = {
    artifact_prefix = "math_sin_",
}
luzer.Fuzz(TestOneInput, nil, args)
