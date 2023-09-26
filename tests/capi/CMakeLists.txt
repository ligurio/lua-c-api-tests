add_library(fuzzer_config INTERFACE)

target_compile_options(
    fuzzer_config
    INTERFACE
        $<$<NOT:$<BOOL:${OSS_FUZZ}>>:
        -fsanitize=fuzzer
        >
        $<$<BOOL:${OSS_FUZZ}>:
        ${CXX}
        ${CXXFLAGS}
        >
)

# `-lc++` is required by Centipede.
# Some references are defined in `libc++` and used by Centipede,
# so -lc++ needs to come after centipede's lib.
target_link_libraries(
    fuzzer_config
    INTERFACE
        $<$<NOT:$<BOOL:${OSS_FUZZ}>>:
        -fsanitize=fuzzer
        >
        $<$<BOOL:${OSS_FUZZ}>:
        $ENV{LIB_FUZZING_ENGINE}
        -lc++
        >
)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(LDFLAGS "${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

if (ENABLE_ASAN)
  set(LDFLAGS "${LDFLAGS} -fsanitize=address")
endif (ENABLE_ASAN)

if (ENABLE_UBSAN)
  set(LDFLAGS "${LDFLAGS} -fsanitize=undefined")
endif (ENABLE_UBSAN)

if (ENABLE_COV)
  set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fcoverage-mapping")
endif (ENABLE_COV)

set(DEFAULT_RUNS_NUMBER 5)

string(JOIN " " LIBFUZZER_OPTS
  -mutate_depth=20
  -print_final_stats=1
  -print_pcs=1
  -reduce_inputs=1
  -reload=1
  -report_slow_units=5
  -workers=${CMAKE_BUILD_PARALLEL_LEVEL}
  -runs=$\{RUNS:-${DEFAULT_RUNS_NUMBER}\}
  -use_value_profile=1
)

function(create_test)
  cmake_parse_arguments(
    FUZZ
    ""
    "FILENAME"
    "SOURCES;LIBRARIES"
    ${ARGN}
  )
  get_filename_component(test_name ${FUZZ_FILENAME} NAME_WE)
  add_executable(${test_name} ${FUZZ_SOURCES})

  target_link_libraries(${test_name} PUBLIC fuzzer_config ${FUZZ_LIBRARIES} ${LUA_LIBRARIES} ${LDFLAGS})
  target_include_directories(${test_name} PRIVATE ${LUA_INCLUDE_DIR})
  target_compile_options(${test_name} PRIVATE -Wall -Wextra -Wpedantic -Wno-unused-parameter -g)
  add_dependencies(${test_name} ${LUA_TARGET})
  string(REPLACE "_test" "" test_prefix ${test_name})
  set(LIBFUZZER_OPTS "${LIBFUZZER_OPTS} -artifact_prefix=${test_name}_")
  if (USE_LUAJIT AND (${test_name} STREQUAL "lua_dump_test"))
    set(LIBFUZZER_OPTS "${LIBFUZZER_OPTS} -only_ascii=1")
  endif ()
  if (USE_LUAJIT AND (${test_name} STREQUAL "lua_load_test"))
    set(LIBFUZZER_OPTS "${LIBFUZZER_OPTS} -only_ascii=1")
  endif ()
  set(dict_path ${PROJECT_SOURCE_DIR}/corpus/${test_name}.dict)
  set(corpus_path ${PROJECT_SOURCE_DIR}/corpus/${test_prefix})
  if (EXISTS ${dict_path})
    set(LIBFUZZER_OPTS "${LIBFUZZER_OPTS} -dict=${dict_path}")
  endif ()
  if (EXISTS ${corpus_path})
    set(LIBFUZZER_OPTS "${LIBFUZZER_OPTS} ${corpus_path}")
  endif ()
  add_test(NAME ${test_name}
           COMMAND ${SHELL} -c "$<TARGET_FILE:${test_name}> ${LIBFUZZER_OPTS}"
  )
  message(STATUS "Creating Lua C API test ${test_name}")
  if (USE_LUA)
    set_tests_properties(${test_name} PROPERTIES
      ENVIRONMENT "ASAN_OPTIONS='detect_invalid_pointer_pairs=2'"
    )
  endif (USE_LUA)
  set_tests_properties(${test_name} PROPERTIES
    LABELS capi
  )

  if (USE_LUAJIT)
    target_compile_definitions(${test_name} PUBLIC LUAJIT)
  endif (USE_LUAJIT)
endfunction()

# These Lua C functions are unsupported by LuaJIT.
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_addgsub_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_bufflen_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffsub_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffaddr_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "lua_stringtonumber_test")
# Disabled because assertion is triggered
# LuaJIT ASSERT lj_bcread.c:123: bcread_byte: buffer read overflow.
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_dostring_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_loadbuffer_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_loadstring_test")

file(GLOB tests LIST_DIRECTORIES false ${CMAKE_CURRENT_SOURCE_DIR} *.c *.cc)
foreach(filename ${tests})
  get_filename_component(test_name ${filename} NAME_WE)
  if (USE_LUAJIT AND (${test_name} IN_LIST LUAJIT_BLACKLIST_TESTS))
    continue()
  endif ()
  if ((${test_name} IN_LIST BLACKLIST_TESTS))
    continue()
  endif ()
  create_test(FILENAME ${test_name}
              SOURCES ${filename}
              LIBRARIES "")
endforeach()

include(ProtobufMutator)
add_subdirectory(luaL_loadbuffer_proto)
if(USE_LUAJIT)
  add_subdirectory(ffi_cdef_proto)
endif ()
