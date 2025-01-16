--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.4 – String Manipulation
https://www.lua.org/manual/5.3/manual.html#6.4

string.byte gets confused with some out-of-range negative indices,
https://www.lua.org/bugs.html#5.1.3-9
]]

-- Synopsis: string.byte(s [, i [, j]])

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    os.setlocale(test_lib.random_locale(fdp), "all")
    local str = fdp:consume_string(test_lib.MAX_STR_LEN)
    local i = fdp:consume_integer(0, test_lib.MAX_INT)
    local j = fdp:consume_integer(0, test_lib.MAX_INT)
    -- `string.byte()` is the same as `str:byte()`.
    assert(string.byte(str, i, j) == str:byte(i, j))
    local char_code = string.byte(str, i, j)
    if char_code then
        assert(type(char_code) == "number")
        local byte = string.char(char_code)
        assert(byte)
        assert(byte == str)
    end
end

local args = {
    artifact_prefix = "string_byte_",
}
luzer.Fuzz(TestOneInput, nil, args)
