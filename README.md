<table>
  <tr>
    <th>PUC Rio Lua</th>
    <td><a href="https://bugs.chromium.org/p/oss-fuzz/issues/list?sort=-opened&can=1&q=proj:lua"><img src="https://oss-fuzz-build-logs.storage.googleapis.com/badges/lua.svg"></a></td>
  </tr>
</table>

# Lua C API tests

is a set of fuzzing tests for C implementations of Lua runtime (PUC Rio Lua and
LuaJIT).

### Building

```sh
git clone --jobs $(nproc) --recursive https://github.com/ligurio/lua-c-api-tests
CC=clang CXX=clang++ cmake -S . -B build -DUSE_LUA=ON [-DUSE_LUAJIT=ON]
cmake --build build --parallel
```

CMake options:

- `USE_LUA` enables building PUC Rio Lua.
- `USE_LUAJIT` enables building LuaJIT.
- `LUA_VERSION` could be a Git branch, tag or commit. By default `LUA_VERSION` is
`master` for PUC Rio Lua and `v2.1` for LuaJIT.
- `ENABLE_ASAN` enables AddressSanitizer.
- `ENABLE_UBSAN` enables UndefinedBehaviorSanitizer.
- `ENABLE_COV` enables coverage instrumentation.

### Running

```sh
cmake --build build --target test
cd build && ctest -R luaL_gsub_test --verbose
```

### References

- [Lua 5.4 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.4/manual.html#4)
- [Lua 5.3 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.3/manual.html#4)
- [Lua 5.2 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.2/manual.html#4)
- [Lua 5.1 Reference Manual: 3 – The Application Program Interface](https://www.lua.org/manual/5.1/manual.html#3)

### License

ISC License, [Sergey Bronnikov](https://bronevichok.ru/)
