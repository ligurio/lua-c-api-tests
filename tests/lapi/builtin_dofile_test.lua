--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: dofile([filename])
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    local chunk_filename = os.tmpname()
    local fh = io.open(chunk_filename, "w")
    fh:write(buf)
    fh:close()
    pcall(dofile, chunk_filename)
    os.remove(chunk_filename)
end

local args = {
    artifact_prefix = "builtin_dofile_",
    -- lj_bcread.c:123: bcread_byte: buffer read overflow
    only_ascii = 1,
}
luzer.Fuzz(TestOneInput, nil, args)
