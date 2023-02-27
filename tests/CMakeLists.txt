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

if (ENABLE_ASAN)
  set(LDFLAGS "-fsanitize=address")
endif (ENABLE_ASAN)

if (ENABLE_UBSAN)
  set(LDFLAGS "-fsanitize=undefined")
endif (ENABLE_UBSAN)

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
endfunction()

file(GLOB_RECURSE tests ${CMAKE_CURRENT_SOURCE_DIR} *.c)
foreach(path ${tests})
  get_filename_component(test_name ${path} NAME)
  string(REPLACE ".c" ";" NAME ${test_name})
  list(GET NAME 0 HEAD)
  create_test(PREFIX ${HEAD})
endforeach()
