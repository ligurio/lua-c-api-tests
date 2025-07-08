--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

6.9 – Operating System Facilities
https://www.lua.org/manual/5.3/manual.html#6.9

Synopsis: os.setlocale(locale [, category])
]]

local luzer = require("luzer")

local function TestOneInput(buf)
    os.setlocale(buf)
end

local args = {
    artifact_prefix = "os_setlocale_",
}
luzer.Fuzz(TestOneInput, nil, args)
