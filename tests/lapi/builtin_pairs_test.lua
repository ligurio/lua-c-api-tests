--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

5.1 – Basic Functions
https://www.lua.org/manual/5.1/manual.html

Assertion failure 'rec_check_slots: slot type mismatch' during pairs iteration,
https://github.com/LuaJIT/LuaJIT/issues/796

infinite loop with pairs() and profiling,
https://github.com/LuaJIT/LuaJIT/issues/754

JIT On with pairs() leads to infinite(ish?) loop,
https://github.com/LuaJIT/LuaJIT/issues/744

Table iteration with `pairs()` does not result in the same order?
https://luajit.org/faq.html

Synopsis: pairs(t)
]]

local luzer = require("luzer")
local test_lib = require("lib")

local function TestOneInput(buf)
    local fdp = luzer.FuzzedDataProvider(buf)
    local items = fdp:consume_integer(0, test_lib.MAX_INT)
    local tbl = fdp:consume_integers(test_lib.MIN_INT, test_lib.MAX_INT, items)
    for _, _ in pairs(tbl) do end
end

local args = {
    artifact_prefix = "builtin_pairs_",
}
luzer.Fuzz(TestOneInput, nil, args)
