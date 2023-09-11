<table>
  <tr>
    <th>PUC Rio Lua</th>
    <td><a href="https://bugs.chromium.org/p/oss-fuzz/issues/list?sort=-opened&can=1&q=proj:lua"><img src="https://oss-fuzz-build-logs.storage.googleapis.com/badges/lua.svg"></a></td>
    <td><a href="https://github.com/ispras/oss-sydr-fuzz/tree/master/projects/lua"><img src="https://img.shields.io/static/v1?label=oss-sydr-fuzz&message=fuzzing&color=brightgreen"></a></td>
  </tr>
  <tr>
    <th>LuaJIT</th>
    <td></td>
    <td><a href="https://github.com/ispras/oss-sydr-fuzz/tree/master/projects/luajit"><img src="https://img.shields.io/static/v1?label=oss-sydr-fuzz&message=fuzzing&color=brightgreen"></a></td>
  </tr>
</table>

# Lua C API tests

is a set of fuzzing tests for C implementations of Lua runtime (PUC Rio Lua and
LuaJIT).

### Building

```sh
git clone --jobs $(nproc) --recursive https://github.com/ligurio/lua-c-api-tests
CC=clang CXX=clang++ cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DUSE_LUA=ON [-DUSE_LUAJIT=ON]
cmake --build build --parallel
```

CMake options:

- `USE_LUA` enables building PUC Rio Lua.
- `USE_LUAJIT` enables building LuaJIT.
- `LUA_VERSION` could be a Git branch, tag or commit. By default `LUA_VERSION` is
`master` for PUC Rio Lua and `v2.1` for LuaJIT.
- `ENABLE_LUAJIT_RANDOM_RA` enables randomness in a register allocation. Option
is LuaJIT-specific.
- `ENABLE_ASAN` enables AddressSanitizer.
- `ENABLE_UBSAN` enables UndefinedBehaviorSanitizer.
- `ENABLE_COV` enables coverage instrumentation.
- `ENABLE_LUA_ASSERT` enables all assertions inside Lua source code.
- `ENABLE_LUA_APICHECK` enables consistency checks on the C API.
- `OSS_FUZZ` enables support of OSS Fuzz.
- `ENABLE_BUILD_PROTOBUF` enables building Protobuf library, otherwise system
  library is used.

### Running

```sh
cmake --build build --target test
cd build && RUNS=100000 ctest -R luaL_gsub_test --verbose
<snipped>
1: Done 100000 runs in 5 second(s)
```

### References

- [Lua 5.4 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.4/manual.html#4)
- [Lua 5.3 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.3/manual.html#4)
- [Lua 5.2 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.2/manual.html#4)
- [Lua 5.1 Reference Manual: 3 – The Application Program Interface](https://www.lua.org/manual/5.1/manual.html#3)

### License

ISC License, [Sergey Bronnikov](https://bronevichok.ru/)
