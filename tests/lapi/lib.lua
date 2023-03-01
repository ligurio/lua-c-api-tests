--[[
SPDX-License-Identifier: ISC
Copyright (c) 2023-2025, Sergey Bronnikov.

Test helpers.
]]

-- The function determines a Lua version.
local function lua_version()
    local is_luajit, _ = pcall(require, "jit")
    if is_luajit then
        return "LuaJIT"
    end

    return _VERSION
end

-- By default `lua_Integer` is ptrdiff_t in Lua 5.1 and Lua 5.2
-- and `long long` in Lua 5.3+, (usually a 64-bit two-complement
-- integer), but that can be changed to `long` or `int` (usually a
-- 32-bit two-complement integer), see LUA_INT_TYPE in
-- <luaconf.h>. Lua 5.3+ has two functions: `math.maxinteger` and
-- `math.mininteger` that returns an integer with the maximum
-- value for an integer and an integer with the minimum value for
-- an integer, see [1] and [2].

-- `0x7ffffffffffff` is a maximum integer in `long long`, however
-- this number is not representable in `double` and the nearest
-- number representable in `double` is `0x7ffffffffffffc00`.
--
-- 1. https://www.lua.org/manual/5.1/manual.html#lua_Integer
-- 2. https://www.lua.org/manual/5.3/manual.html#lua_Integer
local MAX_INT64 = math.maxinteger or  0x7ffffffffffffc00
local MIN_INT64 = math.mininteger or -0x8000000000000000
-- 32-bit integers
local MAX_INT =  0x7fffffff
local MIN_INT = -0x80000000

local function bitwise_op(op_name)
    return function(...)
        local n = select("#", ...)
        local chunk
        -- Bitwise exclusive OR and bitwise NOT have the same
        -- operator.
        if (op_name == "&" or op_name == "|") then
            assert(n > 1)
        end
        if n == 1 then
            local x = ...
            chunk = ("return %s %d"):format(op_name, x)
        else
            local op_name_ws = (" %s "):format(op_name)
            chunk = "return " .. table.concat({...}, op_name_ws)
        end
        return assert(load(chunk))()
    end
end

return {
    lua_version = lua_version,
    bitwise_op = bitwise_op,
    MAX_INT64 = MAX_INT64,
    MIN_INT64 = MIN_INT64,
    MAX_INT = MAX_INT,
    MIN_INT = MIN_INT,
}
