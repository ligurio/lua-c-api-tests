--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Synopsis: loadfile([filename])
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    local chunk_filename = os.tmpname()
    local fh = io.open(chunk_filename, "w")
    fh:write(buf)
    fh:close()

    pcall(loadfile, chunk_filename)

    os.remove(chunk_filename)
end

local args = {
    artifact_prefix = "builtin_loadfile_",
}
luzer.Fuzz(TestOneInput, nil, args)
