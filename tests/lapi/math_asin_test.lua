--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

18 – The Mathematical Library
https://www.lua.org/pil/18.html

6.7 – Mathematical Functions
https://www.lua.org/manual/5.3/manual.html#6.7

Synopsis: math.asin(x)
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_number(-1, 1)
    local y = math.asin(x)
    assert(y >= -math.pi / 2)
    assert(y <=  math.pi / 2)
    -- FIXME: assert(math.sin(y) == x)
end

local args = {
    artifact_prefix = "math_asin_",
}
luzer.Fuzz(TestOneInput, nil, args)
