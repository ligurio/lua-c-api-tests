set(CFLAGS -Wall -Wextra -Wpedantic -Wno-unused-parameter)

if (ENABLE_COV)
  set(CFLAGS ${CFLAGS} -fprofile-instr-generate -fprofile-arcs
             -fcoverage-mapping -ftest-coverage)
  set(LDFLAGS ${LDFLAGS} -fprofile-instr-generate -fprofile-arcs
              -fcoverage-mapping -ftest-coverage)
endif (ENABLE_COV)

set(LIB_LUA_MUTATE lua_mutate)
add_library(${LIB_LUA_MUTATE} STATIC mutate.c)
target_link_libraries(${LIB_LUA_MUTATE} PRIVATE ${LUA_LIBRARIES} ${LDFLAGS})
target_include_directories(${LIB_LUA_MUTATE} PRIVATE ${LUA_INCLUDE_DIR})
target_compile_options(${LIB_LUA_MUTATE} PRIVATE ${CFLAGS})
add_dependencies(${LIB_LUA_MUTATE} ${LUA_TARGET})

set(LIB_LUA_CROSSOVER lua_crossover)
add_library(${LIB_LUA_CROSSOVER} STATIC crossover.c)
target_link_libraries(${LIB_LUA_CROSSOVER} PRIVATE ${LUA_LIBRARIES} ${LDFLAGS})
target_include_directories(${LIB_LUA_CROSSOVER} PRIVATE ${LUA_INCLUDE_DIR})
target_compile_options(${LIB_LUA_CROSSOVER} PRIVATE ${CFLAGS})
add_dependencies(${LIB_LUA_CROSSOVER} ${LUA_TARGET})

if (ENABLE_INTERNAL_TESTS)
  add_subdirectory(tests)
endif()
