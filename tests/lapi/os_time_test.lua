--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.9 – Operating System Facilities
https://www.lua.org/manual/5.3/manual.html#6.9

Synopsis: os.time([table])
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT64 = test_lib.MAX_INT64

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local time = {
        isdst = fdp:consume_boolean(),
        sec = fdp:consume_number(0, MAX_INT64),
        min = fdp:consume_number(0, MAX_INT64),
        hour = fdp:consume_number(0, MAX_INT64),
        day = fdp:consume_number(0, MAX_INT64),
        month = fdp:consume_number(0, MAX_INT64),
        year = fdp:consume_number(0, MAX_INT64),
    }
    os.time(time)
end

local args = {
    artifact_prefix = "os_time_",
}
luzer.Fuzz(TestOneInput, nil, args)
