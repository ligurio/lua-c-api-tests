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
target_link_libraries(
    fuzzer_config
    INTERFACE
        $<$<NOT:$<BOOL:${OSS_FUZZ}>>:
        -fsanitize=fuzzer
        >
        $<$<BOOL:${OSS_FUZZ}>:
        $ENV{LIB_FUZZING_ENGINE}
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
  string(JOIN " " LIBFUZZER_OPTS
    -use_value_profile=1
    -report_slow_units=5
    -reload=1
    -reduce_inputs=1
    -print_pcs=1
    -print_final_stats=1
    -mutate_depth=20
    -runs=$\{RUNS:-${DEFAULT_RUNS_NUMBER}\}
    -artifact_prefix=${test_name}_
  )
  add_test(NAME ${test_name}
           COMMAND ${SHELL} -c "$<TARGET_FILE:${test_name}> ${LIBFUZZER_OPTS}"
  )
  if (USE_LUA)
    set_tests_properties(${test_name} PROPERTIES
      ENVIRONMENT "ASAN_OPTIONS='detect_invalid_pointer_pairs=2'"
    )
  endif (USE_LUA)

  if (USE_LUAJIT)
    target_compile_definitions(${test_name} PUBLIC LUAJIT)
  endif (USE_LUAJIT)
endfunction()

list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_addgsub_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_bufflen_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffsub_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffaddr_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "lua_load_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "lua_stringtonumber_test")

# https://github.com/ligurio/lua-c-api-tests/issues/19
list(APPEND BLACKLIST_TESTS "luaL_dostring_test")
list(APPEND BLACKLIST_TESTS "luaL_loadbuffer_test")
list(APPEND BLACKLIST_TESTS "luaL_loadstring_test")

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
