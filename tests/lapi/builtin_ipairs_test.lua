--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: ipairs(t)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local items = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_integers(test_lib.MIN_INT, test_lib.MAX_INT, items)
    for _, _ in ipairs(tbl) do end
end

local args = {
    artifact_prefix = "builtin_ipairs_",
}
luzer.Fuzz(TestOneInput, nil, args)
