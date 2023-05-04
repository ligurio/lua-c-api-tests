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

function(create_test)
  cmake_parse_arguments(
    FUZZ
    ""
    "PREFIX"
    ""
    ${ARGN}
  )
  add_executable(${FUZZ_PREFIX} ${FUZZ_PREFIX}.c)
  target_link_libraries(${FUZZ_PREFIX} PUBLIC fuzzer_config ${LUA_LIBRARIES} ${LDFLAGS})
  target_include_directories(${FUZZ_PREFIX} PRIVATE ${LUA_INCLUDE_DIR})
  target_compile_options(${FUZZ_PREFIX} PRIVATE -Wall -Wextra -Wpedantic -Wno-unused-parameter -g)
  add_dependencies(${FUZZ_PREFIX} ${LUA_TARGET})
  add_test(NAME ${FUZZ_PREFIX}
           COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${FUZZ_PREFIX}
                   -use_value_profile=1
                   -report_slow_units=5
                   -reload=1
                   -reduce_inputs=1
                   -print_pcs=1
                   -print_final_stats=1
                   -mutate_depth=20
                   -max_total_time=10
                   -artifact_prefix=${FUZZ_PREFIX}
  )
  if (USE_LUA)
    set_tests_properties(${FUZZ_PREFIX} PROPERTIES
      ENVIRONMENT "ASAN_OPTIONS='detect_invalid_pointer_pairs=2'"
    )
  endif (USE_LUA)

  if (USE_LUAJIT)
    target_compile_definitions(${FUZZ_PREFIX} PUBLIC LUAJIT)
  endif (USE_LUAJIT)
endfunction()

list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_bufflen_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffsub_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "luaL_buffaddr_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "lua_load_test")
list(APPEND LUAJIT_BLACKLIST_TESTS "lua_stringtonumber_test")

file(GLOB_RECURSE tests ${CMAKE_CURRENT_SOURCE_DIR} *.c)
foreach(path ${tests})
  get_filename_component(test_name ${path} NAME)
  string(REPLACE ".c" ";" NAME ${test_name})
  list(GET NAME 0 HEAD)
  if (USE_LUAJIT AND (${HEAD} IN_LIST LUAJIT_BLACKLIST_TESTS))
    continue()
  endif ()
  create_test(PREFIX ${HEAD})
endforeach()

include(ProtobufMutator)
add_subdirectory(luaL_loadbuffer_proto)
