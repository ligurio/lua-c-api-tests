-- Defined functions is unused in preamble,
-- but could be used by generated Lua programs.
files["tests/capi/luaL_loadbuffer_proto/preamble.lua"] = {
    ignore = {
        "211",
    },
}

-- The new function introduced in the Lua 5.5, it is not yet
-- supported by the luacheck, see [1].
--
-- 1. https://github.com/lunarmodules/luacheck/issues/132
globals = {
    table = {
        fields = { "create" }
    }
}
