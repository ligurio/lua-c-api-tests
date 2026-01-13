### PUC Rio Lua

1. "Re: More disciplined use of 'getstr' and 'tsslen'",
   https://marc.info/?l=lua-l&m=169289729129364&w=2#2
   https://github.com/lua/lua/commit/9b4f39ab14fb2e55345c3d23537d129dac23b091
1. Stack overflow in `getobjname`,
   https://marc.info/?l=lua-l&m=169867263111530&w=2,
   https://github.com/lua/lua/commit/7923dbbf72da303ca1cca17efd24725668992f15
1. Heap buffer overflow in `luaC_newobjdt`,
   https://marc.info/?l=lua-l&m=170274071304413&w=2
   https://github.com/lua/lua/commit/5853c37a83ec66ccb45094f9aeac23dfdbcde671
1. "heap-use-after-free" issue in `luaV_finishget`,
   https://groups.google.com/g/lua-l/c/s2hBcf8aLIU,
   https://oss-fuzz.com/testcase-detail/5350818532360192,
   https://github.com/lua/lua/commit/88a50ffa715483e7187c0d7d6caaf708ebacf756
1. Assertion in `luaK_codeABCk`,
   https://groups.google.com/g/lua-l/c/H0Iq-eAig94,
   https://oss-fuzz.com/testcase-detail/5166379907481600
1. An assertion is triggered in `lgc.c:freeobj()`,
   https://groups.google.com/g/lua-l/c/CCpPLX1ug3A,
   https://oss-fuzz.com/testcase-detail/6073198411579392,
   https://github.com/lua/lua/commit/f9e35627ed26dff4114a1d01ff113d8b4cc91ab5
1. UBsan: member access within null pointer of type 'struct TString',
   https://groups.google.com/g/lua-l/c/Kng6FGlPjmc,
   https://github.com/lua/lua/commit/6d53701c7a0dc4736d824fd891ee6f22265d0d68,
   https://oss-fuzz.com/testcase-detail/5557969930747904
1. Assertion failure of `A <= ((1<<8)-1) && B <= ((1<<8)-1) && C <= ((1<<8)-1) && (k & ~1) == 0`,
   https://groups.google.com/g/lua-l/c/F132crJ2D_8
   https://github.com/ligurio/lunapark/issues/155
1. An assertion is triggered in `luaK_storevar`,
   https://groups.google.com/g/lua-l/c/Cfb5Yn0aJEU
   https://issues.oss-fuzz.com/issues/455148340,
   https://oss-fuzz.com/testcase-detail/5818389013790720
1. Memory leak on execution a Lua chunk,
   https://groups.google.com/g/lua-l/c/iknlDQ_slus
   https://oss-fuzz.com/testcase-detail/6216394992844800
   https://issues.oss-fuzz.com/issues/467095524
   https://github.com/lua/lua/commit/a5522f06d2679b8f18534fd6a9968f7eb539dc31
1. A signed integer overflow in `lua_gc`,
   https://oss-fuzz.com/testcase-detail/6260291328606208
   https://issues.oss-fuzz.com/issues/466669138
   https://groups.google.com/g/lua-l/c/WWVjDfGeyvs
   https://github.com/lua/lua/commit/632a71b24d8661228a726deb5e1698e9638f96d8
   https://www.lua.org/bugs.html#5.5.0-1
1. Undefined behavior in `utf8_decode()`,
   https://groups.google.com/g/lua-l/c/5TqwqKe1MF8
   https://github.com/lua/lua/commit/10eb89d1141dc528806b32401e408e36fb2f3bf5
   https://www.lua.org/bugs.html#5.5.0-3
1. An assertion is triggered in the `luaG_runerror()`,
   https://groups.google.com/g/lua-l/c/GCgcboFoDf8
   https://issues.oss-fuzz.com/issues/511579745
   https://oss-fuzz.com/testcase-detail/6530878632427520
   https://github.com/lua/lua/commit/0465c23b3ee214ea3a117ab9d69a83cf85e7a82f
1. A heap-use-after-free is triggered in the `insertkey()`,
   https://groups.google.com/g/lua-l/c/K2mvG0mjwow
   https://issues.oss-fuzz.com/issues/508107730
   https://oss-fuzz.com/testcase-detail/6274756486955008
   https://www.lua.org/bugs.html#5.5.0-8
   https://github.com/lua/lua/commit/b996f8fd1be7fb711cc6f754a31a1c87d2c2fd9b

### LuaJIT

1. ASSERT: `lj_obj_equal(tv, &tvk)`,
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=57435,
   https://github.com/LuaJIT/LuaJIT/issues/9
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
1. Heap-use-after-free in `lj_gc_finalize_cdata` on access to `CTState->finalizer`,
   https://github.com/LuaJIT/LuaJIT/issues/1168
1. Down-recursion of a side trace may corrupt the host stack,
   https://github.com/LuaJIT/LuaJIT/issues/1169
1. GC64 mode may overflow the `LJ_MAX_JSLOTS` limit for a stitched trace.,
   https://github.com/LuaJIT/LuaJIT/issues/1173
1. State not restored during recording if `__concat` metamethod throws an error,
   https://github.com/LuaJIT/LuaJIT/issues/1234
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=69897
1. Uninitialized `cts->L` and error handling issues in `recff_cdata_arith`,
   https://github.com/LuaJIT/LuaJIT/issues/1224
1. OOM errors during GC step raising in the context of a JIT trace,
   https://github.com/LuaJIT/LuaJIT/issues/1247,
   https://github.com/tarantool/tarantool/issues/10290
1. stack-buffer-overflow in `narrow_conv_backprop`,
   https://github.com/LuaJIT/LuaJIT/issues/1262,
   https://oss-fuzz.com/testcase?key=6250635821907968
1. Incorrect recording of `getmetatable()` for IO handlers,
   https://github.com/LuaJIT/LuaJIT/issues/1279
1. Uninitialized read in `predict_next()`,
   https://oss-fuzz.com/testcase-detail/5091141278564352
   https://github.com/LuaJIT/LuaJIT/issues/1226
1. State is not restored during recording `__concat` metamethod in case of the OOM,
   https://github.com/LuaJIT/LuaJIT/issues/1298,
   https://issues.oss-fuzz.com/issues/372358472
1. Unsinking the table with `IRFL_TAB_NOMM` leads to the assertion failure,
   https://github.com/LuaJIT/LuaJIT/issues/1052
1. Multi-concat recording doesn't handle vararg/protected frames,
   https://github.com/LuaJIT/LuaJIT/issues/1164
1. Incorrect narrowing for huge numbers,
   https://github.com/LuaJIT/LuaJIT/issues/1236
1. Assertion failure when flushing already flushed trace,
   https://github.com/LuaJIT/LuaJIT/issues/1345
1. Read from already collected string data in case of the error in loadfile,
   https://github.com/LuaJIT/LuaJIT/issues/1353,
   https://github.com/tarantool/security/issues/144,
   https://issues.oss-fuzz.com/issues/407592872
1. JIT slots overflow for side-trace after up-recursion,
   https://github.com/LuaJIT/LuaJIT/issues/1358,
   https://github.com/tarantool/security/issues/145
1. Stack overflow in error handler during stack overflow,
   https://github.com/LuaJIT/LuaJIT/issues/1152,
   https://issues.oss-fuzz.com/issues/394126186,
   https://github.com/tarantool/security/issues/143
1. Missed type conversion for already existent slots in DUALNUM mode,
   https://github.com/LuaJIT/LuaJIT/issues/1413
1. AddressSanitizer: heap-buffer-overflow in `blacklist_pc()`,
   https://github.com/tarantool/security/issues/139
   https://github.com/LuaJIT/LuaJIT/issues/1403
1. Duality of 0 in `DUALNUM` build and `BC_UNM`,
   https://github.com/LuaJIT/LuaJIT/issues/1422
1. `lj_record.c`:164: `rec_check_slots`: slot 25 type mismatch: stack type 13 vs IR type 0
   https://github.com/tarantool/security/issues/154
   https://oss-fuzz.com/testcase-detail/4952098017181696
1. Incorrect -0 direction for JITed loop,
   https://github.com/LuaJIT/LuaJIT/issues/1432
1. UBSan warning for too big indices in `unpack()`,
   https://github.com/LuaJIT/LuaJIT/issues/1450
1. pcall as metamethod can overflow stack,
   https://github.com/LuaJIT/LuaJIT/issues/1048,
   https://github.com/tarantool/security/issues/147
   https://issues.oss-fuzz.com/issues/435479026
   https://oss-fuzz.com/testcase-detail/6399895872536576
1. UBSan warning for too small month and year values in `os.time()`,
   https://github.com/LuaJIT/LuaJIT/issues/1454
1. UBSan warning for too big hash size in `table.new()`,
   https://github.com/LuaJIT/LuaJIT/issues/1458
1. UBSan warning in `carith_ptr()`,
   https://github.com/LuaJIT/LuaJIT/issues/1459
   https://github.com/tarantool/security/issues/142
   https://issues.oss-fuzz.com/issues/393404275
1. Heap overflow of Lua stack after relimiting,
   https://github.com/LuaJIT/LuaJIT/issues/1471
   https://issues.oss-fuzz.com/issues/507646002
1. Narrowing of unary minus operation for number 0 in DUALNUM mode,
   https://github.com/LuaJIT/LuaJIT/issues/1418
1. Incorrect -0 direction for JITed loop,
   https://github.com/LuaJIT/LuaJIT/issues/1432

### Tarantool

1. Assertion `'ls->p < ls->pe'` failed: `lj_bcread.c:122: uint32_t bcread_byte(LexState *)`,
   https://github.com/tarantool/tarantool/issues/4824
1. Fix narrowing of unary minus,
   https://github.com/tarantool/tarantool/issues/6976
1. ASSERT: `lj_obj_equal(tv, &tvk)`,
   https://github.com/LuaJIT/LuaJIT/issues/9
   https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=57435
1. Recording of `__concat` in GC64 mode,
   https://github.com/LuaJIT/LuaJIT/issues/839
1. Heap buffer overflow in the `lj_strfmt_pushvf` on stack overflow,
   https://issues.oss-fuzz.com/issues/394126186,
   https://github.com/tarantool/security/issues/143
1. `IR_NEWREF` is missing a NaN check,
   https://issues.oss-fuzz.com/issues/42529868
   https://github.com/LuaJIT/LuaJIT/issues/1069
1. Heap-buffer overflow in `lex_string()`,
   https://github.com/tarantool/security/issues/153
   https://github.com/tarantool/tarantool/commit/ea71e2c3be2f5271e0cfd86ff63d36f97d484c7f

### Related issues

1. https://www.lua.org/bugs.html
1. https://github.com/google/oss-fuzz-vulns/tree/main/vulns/lua
1. https://oss-fuzz.com/testcases?project=lua&open=yes
1. https://github.com/tarantool/tarantool/wiki/Fuzzing
