set(ENV_NAME_PATH "LIBFUZZER_LUA_SCRIPT")

add_executable(mutator_basic_test mutator_basic_test.c)
target_include_directories(mutator_basic_test PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(mutator_basic_test PRIVATE ${LUA_LIBRARIES}
                                                 ${LDFLAGS}
                                                 ${LIB_LUA_MUTATE})
target_compile_options(mutator_basic_test PRIVATE ${CFLAGS})
add_test(
  NAME libluamut_mutator_basic_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/mutator_basic_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_mutator_basic_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_basic.lua"
  LABELS internal
)
add_test(
  NAME libluamut_mutator_no_script_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/mutator_basic_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_mutator_no_script_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=unknown"
  PASS_REGULAR_EXPRESSION "is not accessible"
  LABELS internal
)

add_executable(mutator_seed_test mutator_seed_test.c)
target_include_directories(mutator_seed_test PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(mutator_seed_test PRIVATE ${LUA_LIBRARIES}
                                                ${LDFLAGS}
                                                ${LIB_LUA_MUTATE})
target_compile_options(mutator_seed_test PRIVATE ${CFLAGS})
add_test(
  NAME libluamut_mutator_seed_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/mutator_seed_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_mutator_seed_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_seed.lua"
  LABELS internal
)

add_executable(mutator_e2e_test mutator_e2e_test.c)
target_include_directories(mutator_e2e_test PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(mutator_e2e_test PRIVATE ${LUA_LIBRARIES}
                                               ${LDFLAGS} -fsanitize=fuzzer
                                               ${LIB_LUA_MUTATE})
target_compile_options(mutator_e2e_test PRIVATE ${CFLAGS} -fsanitize=fuzzer)
add_test(
  NAME libluamut_mutator_e2e_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/mutator_e2e_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_mutator_e2e_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_e2e.lua"
  PASS_REGULAR_EXPRESSION "BINGO: Found the target, exiting."
  LABELS internal
)

add_executable(crossover_basic_test crossover_basic_test.c)
target_include_directories(crossover_basic_test PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(crossover_basic_test PRIVATE
                      ${LUA_LIBRARIES} ${LDFLAGS} lua_crossover)
target_compile_options(crossover_basic_test PRIVATE ${CFLAGS})
add_test(
  NAME libluamut_crossover_basic_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/crossover_basic_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_crossover_basic_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_basic.lua"
  LABELS internal
)
add_test(
  NAME libluamut_crossover_no_script_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/crossover_basic_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_crossover_no_script_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=unknown"
  PASS_REGULAR_EXPRESSION "is not accessible"
  LABELS internal
)

add_executable(crossover_seed_test crossover_seed_test.c)
target_include_directories(crossover_seed_test PRIVATE
                           ${LUA_INCLUDE_DIR})
target_link_libraries(crossover_seed_test PRIVATE
                      ${LUA_LIBRARIES} ${LDFLAGS} lua_crossover)
target_compile_options(crossover_seed_test PRIVATE ${CFLAGS})
add_test(
  NAME libluamut_crossover_seed_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/crossover_seed_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_crossover_seed_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_seed.lua"
  LABELS internal
)

add_executable(crossover_e2e_test crossover_e2e_test.c)
target_include_directories(crossover_e2e_test PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(crossover_e2e_test PRIVATE
                      ${LUA_LIBRARIES} ${LDFLAGS} -fsanitize=fuzzer lua_crossover)
target_compile_options(crossover_e2e_test PRIVATE ${CFLAGS} -fsanitize=fuzzer)
add_test(
  NAME libluamut_crossover_e2e_test
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/crossover_e2e_test
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
set_tests_properties(libluamut_crossover_e2e_test PROPERTIES
  ENVIRONMENT "${ENV_NAME_PATH}=${CMAKE_CURRENT_SOURCE_DIR}/script_e2e.lua"
  PASS_REGULAR_EXPRESSION "BINGO: Found the target, exiting."
  LABELS internal
)
