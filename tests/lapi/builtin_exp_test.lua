--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

3.1 – Arithmetic Operators
https://www.lua.org/pil/3.1.html
https://www.lua.org/manual/5.1/manual.html#2.5.1

> Lua also offers partial support for `^´ (exponentiation).
> One of the design goals of Lua is to have a tiny core.
> An exponentiation operation (implemented through the `pow`
> function in C) would mean that we should always need to link
> Lua with the C mathematical library.

See properties in
"ESA/390 Enhanced Floating Point Support: An Overview"
(The Facts of Floating Point Arithmetic) [1].

1. http://ftpmirror.your.org/pub/misc/ftp.software.ibm.com/software/websphere/awdtools/hlasm/sh93fpov.pdf
]]

local luzer = require("luzer")
local test_lib = require("lib")
local MAX_INT = test_lib.MAX_INT
local MIN_INT = test_lib.MIN_INT

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local x = fdp:consume_integer(MIN_INT, MAX_INT)
    local y = fdp:consume_integer(MIN_INT, MAX_INT)
    local _ = x ^ y
end

local args = {
    artifact_prefix = "builtin_exp_",
}
luzer.Fuzz(TestOneInput, nil, args)
