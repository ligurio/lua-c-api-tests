--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.len(s)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local str_len = fdp:consume_integer(0, test_lib.MAX_INT)
    local str = fdp:consume_string(str_len)
    assert(string.len(str) == #str)
end

local args = {
    artifact_prefix = "string_len_",
}
luzer.Fuzz(TestOneInput, nil, args)
