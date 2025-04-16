--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.lower(s)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local ch_uppercase = string.char(fdp:consume_integer(65, 65 + 25))
    local ch = string.upper(string.lower(ch_uppercase))
    assert(ch == ch_uppercase)
end

local args = {
    artifact_prefix = "string_lower_",
}
luzer.Fuzz(TestOneInput, nil, args)
