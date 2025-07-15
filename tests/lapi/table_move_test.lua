--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.6 – Table Manipulation,
https://www.lua.org/manual/5.3/manual.html#6.6

Synopsis: table.move(a1, f, e, t [,a2])
]]

local luzer = require("luzer")
local test_lib = require("lib")

if test_lib.lua_version() ~= "LuaJIT" then
    print("Unsupported version.")
    os.exit(0)
end

local function TestOneInput(buf, _size)
    local fdp = luzer.FuzzedDataProvider(buf)
    local count = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_strings(test_lib.MAX_STR_LEN, count)
    local tbl_len = #tbl
    local tbl_new= {}
    -- Move all items from the table `tbl` to the `tbl_new`.
    table.move(tbl, 1, tbl_len, 1, tbl_new)
    assert(tbl[1] == tbl_new[1])
    assert(tbl[tbl_len] == tbl_new[tbl_len])
end

local args = {
    artifact_prefix = "table_move_",
}
luzer.Fuzz(TestOneInput, nil, args)
