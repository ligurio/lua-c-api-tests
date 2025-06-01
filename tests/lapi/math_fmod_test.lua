--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Synopsis: math.fmod(x, y)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local y = fdp:consume_number(test_lib.MIN_INT, test_lib.MAX_INT)
    local res = math.fmod(x, y)
    assert(type(res) == "number")
end

local args = {
    artifact_prefix = "math_fmod_",
}
luzer.Fuzz(TestOneInput, nil, args)
