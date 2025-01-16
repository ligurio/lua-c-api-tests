--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: tostring(e)
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)

    -- Since Lua 5.5 conversion float to string ensures that, for
    -- any float f, `tonumber(tostring(f)) == f`, but still
    -- avoiding noise like 1.1 converting to "1.1000000000000001",
    -- see [1].
    --
    -- 1. https://github.com/lua/lua/commit/1bf4b80f1ace8384eb9dd6f7f8b67256b3944a7a
    local i1 = fdp:consume_integer(MIN_INT, MAX_INT)
    local i2 = tonumber(tostring(i1))
    assert(i1 == i2)
end

local args = {
    artifact_prefix = "builtin_tostring_",
}
luzer.Fuzz(TestOneInput, nil, args)
