--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Missing phi check in bufput_bufstr fold rule,
https://github.com/LuaJIT/LuaJIT/issues/797

Synopsis: string.reverse(s)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local max_len = fdp:consume_integer(1, test_lib.MAX_INT)
    local str = fdp:consume_string(max_len)
    assert(string.reverse(string.reverse(str)) == str)
end

local args = {
    artifact_prefix = "string_reverse_",
}
luzer.Fuzz(TestOneInput, nil, args)
