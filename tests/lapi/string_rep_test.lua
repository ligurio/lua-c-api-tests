--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

Synopsis: string.rep(s, n [, sep])

read overflow in 'l_strcmp',
https://github.com/lua/lua/commit/f623b969325be736297bc1dff48e763c08778243
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local max_len = fdp:consume_integer(0, test_lib.MAX_INT)
    -- Huge length leads to slow units.
    local n = fdp:consume_integer(0, 32768)
    local s = fdp:consume_string(0, max_len)
    local sep = fdp:consume_string(0, max_len)
    local len = string.len(string.rep(s, n, sep))
    assert(len == #s * n + #sep * (n - 1))
end

local args = {
    artifact_prefix = "string_rep_",
}
luzer.Fuzz(TestOneInput, nil, args)
