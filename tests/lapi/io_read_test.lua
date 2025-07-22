--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.7 – Input and Output Facilities
https://www.lua.org/manual/5.1/manual.html#5.7
https://www.lua.org/pil/21.3.html

Synopsis: io.read(...)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local READ_MODE = {
    "*a",
    "*l",
    "*n",
}

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local str = fdp:consume_string(test_lib.MAX_STR_LEN)
    local lua_cmd = ("%s -e '%s'"):format(test_lib.luabin(arg), str)
    local fh = io.popen(lua_cmd, "w")
    local mode = fdp:oneof(READ_MODE)
    local cur_pos = fh:seek()
    fh:seek("end")
    fh:seek("set", cur_pos)
    fh:read(mode)
    fh:flush()
    fh:close()
end

local args = {
    artifact_prefix = "io_read_",
}
luzer.Fuzz(TestOneInput, nil, args)
