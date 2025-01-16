--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.upper(s)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local str = fdp:consume_string(1, test_lib.MAX_INT)
    local str_lowercase = str:lower()
    assert(str_lowercase == str_lowercase:upper():lower())
end

local args = {
    artifact_prefix = "string_upper_",
}
luzer.Fuzz(TestOneInput, nil, args)
