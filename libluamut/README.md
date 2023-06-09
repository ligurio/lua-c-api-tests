### libluamut

is two shared libraries that allows using custom mutation and
crossover functions written in Lua programming language in
LibFuzzer. When defined these Lua functions will be executed
instead default LibFuzzer functions `LLVMFuzzerCustomMutator` and
`LLVMFuzzerCustomCrossover`.

For implementing a custom mutation function in Lua one need to
create a Lua script with a function `LLVMFuzzerCustomMutator` and
set a path to the script in an environment variable with name
`LIBFUZZER_LUA_SCRIPT`. When this environment variable is not set
default script name `libfuzzer_lua_script.lua` will be used.
The same with custom crossover function - one need create
a Lua script with defined Lua function `LLVMFuzzerCustomCrossover`
and set a path to the script in environment variable
`LIBFUZZER_LUA_SCRIPT`.

Pay attention that both functions uses its own Lua state
internally.
