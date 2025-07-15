--[=[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.5 – Table Manipulation,
https://www.lua.org/manual/5.2/manual.html#6.5

Compiler can optimize away overflow check in table.unpack,
https://www.lua.org/bugs.html#5.2.3-1

Synopsis: table.unpack(list [, i [, j]])
--]]=]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT

if test_lib.lua_current_version_lt_than(5, 2) then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local count = fdp:consume_integer(0, test_lib.MAX_INT64)
    local tbl = fdp:consume_strings(test_lib.MAX_STR_LEN, count)
    local i = fdp:consume_integer(0, MAX_INT)
    local j = fdp:consume_integer(0, MAX_INT)
    table.unpack(tbl, i, j)
end

local args = {
    artifact_prefix = "table_unpack_",
}
luzer.Fuzz(TestOneInput, nil, args)
