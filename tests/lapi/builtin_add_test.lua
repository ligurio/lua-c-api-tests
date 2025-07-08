--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

3.1 – Arithmetic Operators
https://www.lua.org/pil/3.1.html
https://www.lua.org/manual/5.1/manual.html#2.5.1

See properties in
"ESA/390 Enhanced Floating Point Support: An Overview"
(The Facts of Floating Point Arithmetic) [1].

1. http://ftpmirror.your.org/pub/misc/ftp.software.ibm.com/software/websphere/awdtools/hlasm/sh93fpov.pdf
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT64 = test_lib.MAX_INT64

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local arg1 = fdp:consume_integer(0, MAX_INT64)
    local arg2 = fdp:consume_integer(0, MAX_INT64)
    local _ = arg1 + arg2
end

local args = {
    artifact_prefix = "builtin_add_",
}
luzer.Fuzz(TestOneInput, nil, args)
