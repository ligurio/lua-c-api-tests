# Lua C API tests

is a set of fuzzing tests for C implementations of Lua runtime (PUC Rio Lua and
LuaJIT).

### Building

```sh
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

### Running

```sh
cmake --build build --target test
```

### Update a seed corpus

```sh
$ ./build/tests/luaL_loadstring_test -set_cover_merge=1 corpus new_corpus
$ ./build/tests/luaL_loadstring_test -merge=1 corpus new_corpus
```

### Collect code coverage

Compile and link with `-fprofile-instr-generate -fcoverage-mapping` options. When
using `-fsanitize=address`, no `.profraw` will be written on crash or abort, so
once the fuzzing test is finished, a second run is needed by passing only files
in corpus, run: `./build/tests/luaL_loadstring_test -runs=0 ./<corpora minimized>`:

```
$ CFLAGS="-fprofile-instr-generate -fcoverage-mapping" CC=clang CXX=clang++ cmake -S . -B build -G Ninja
$ cmake --build build --parallel
$ ./build/tests/luaL_loadstring_test -runs=0
```

Then to generate an html view:

```sh
$ llvm-profdata merge -sparse default.profraw -o default.profdata
$ llvm-cov show --format=html ./build/tests/luaL_loadstring_test -instr-profile=default.profdata > coverage.html
```

Show code coverage for a single function with a name `luaL_loadstring`:

```sh
$ llvm-cov show ./build/tests/luaL_loadstring_test -instr-profile=default.profdata -name=luaL_loadstring
```

<!--
https://github.com/google/fuzzing/blob/master/tutorial/libFuzzerTutorial.md#visualizing-coverage
https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
https://llvm.org/docs/CoverageMappingFormat.html
https://github.com/google/fuzzing/issues/41#issuecomment-1031942660
https://google.github.io/oss-fuzz/advanced-topics/code-coverage/#generate-code-coverage-reports
-->

### References

- [Lua 5.4 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.4/manual.html#4)
- [Lua 5.3 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.3/manual.html#4)
- [Lua 5.2 Reference Manual: 4 – The Application Program Interface](https://www.lua.org/manual/5.2/manual.html#4)
- [Lua 5.1 Reference Manual: 3 – The Application Program Interface](https://www.lua.org/manual/5.1/manual.html#3)

### License

ISC License, Sergey Bronnikov
