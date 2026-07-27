--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2026, Sergey Bronnikov.

6.9 – Operating System Facilities
https://www.lua.org/manual/5.3/manual.html#6.9

Synopsis: os.difftime(t2, t1)
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MIN_INT = test_lib.MIN_INT
local MAX_INT = test_lib.MAX_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    test_lib.random_misc_settings(fdp)
    local t1 = fdp:consume_number(MIN_INT, MAX_INT)
    local t2 = fdp:consume_number(MIN_INT, MAX_INT)
    local ok, res = pcall(os.difftime, t1, t2)
    if not ok then
        return
    end
    assert(type(res) == "number")
end

local args = {
    artifact_prefix = "os_difftime_",
}
luzer.Fuzz(TestOneInput, nil, args)
