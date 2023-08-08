### PUC Rio Lua

1. "Re: More disciplined use of 'getstr' and 'tsslen'",
   https://marc.info/?l=lua-l&m=169289729129364&w=2#2
1. Stack overflow in `getobjname`,
   https://marc.info/?l=lua-l&m=169867263111530&w=2,
   https://github.com/lua/lua/commit/7923dbbf72da303ca1cca17efd24725668992f15

### LuaJIT

1. 0th register may be considered as `RID_NONE` in `asm_head_side`,
   https://github.com/LuaJIT/LuaJIT/issues/1016,
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=58555
1. Use-def analysis for VARG doesn't purge some dead JIT slots
   https://github.com/LuaJIT/LuaJIT/issues/1024
1. ASSERT: `itype2irt(tv) == ((IRType)(((&J->fold.ins)->t).irt & IRT_TYPE))`,
   https://github.com/LuaJIT/LuaJIT/issues/981,
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=57424
1. ASSERT: `bc_isret(((BCOp)((ins[-1])&0xff)))`,
   https://github.com/LuaJIT/LuaJIT/issues/913,
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=57548
1. Crash during parsing in the `predict_next()`,
   https://github.com/LuaJIT/LuaJIT/issues/1033
1. Incorrect PC value in a function `predict_next`,
   https://github.com/LuaJIT/LuaJIT/issues/1054
1. VM handler call on constructed testcase,
   https://github.com/LuaJIT/LuaJIT/issues/1087
1. Red zone overflow on trace compilation,
   https://github.com/LuaJIT/LuaJIT/issues/1116
1. `IR_NEWREF` is missing a NaN check,
   https://github.com/LuaJIT/LuaJIT/issues/1069

### Tarantool

1. Assertion `'ls->p < ls->pe'` failed: `lj_bcread.c:122: uint32_t bcread_byte(LexState *)`,
   https://github.com/tarantool/tarantool/issues/4824
1. Fix narrowing of unary minus,
   https://github.com/tarantool/tarantool/issues/6976
1. ASSERT: `lj_obj_equal(tv, &tvk)`,
   https://github.com/LuaJIT/LuaJIT/issues/9
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=57435
