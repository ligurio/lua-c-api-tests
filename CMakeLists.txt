cmake_minimum_required(VERSION 3.18)

project(lua-c-api-tests
  LANGUAGES C CXX
  VERSION "1.0.0"
)

find_program(SHELL sh)
find_program(ECHO echo)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
set(CMAKE_INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_INCLUDE_PATH})

include(cmake/utils.cmake)

option(USE_LUA "Use PUC Rio Lua library" OFF)
option(USE_LUAJIT "Use LuaJIT library" OFF)
option(ENABLE_ASAN "Enable AddressSanitizer" OFF)
option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer" OFF)
option(ENABLE_COV "Enable coverage instrumentation" OFF)
option(ENABLE_LUA_ASSERT "Enable all assertions inside Lua source code" ON)
option(ENABLE_LUA_APICHECK "Enable consistency checks on the C API" ON)
option(ENABLE_LUAJIT_RANDOM_RA "Enable randomness in a register allocation" OFF)
option(OSS_FUZZ "Enable support of OSS Fuzz" OFF)
option(ENABLE_BUILD_PROTOBUF "Enable building Protobuf library" ON)
option(ENABLE_BONUS_TESTS "Enable bonus tests" OFF)
option(ENABLE_INTERNAL_TESTS "Enable internal tests" OFF)
option(ENABLE_LAPI_TESTS "Enable Lua API tests" OFF)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
set(CMAKE_INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_INCLUDE_PATH})

include(SetBuildParallelLevel)
include(SetHardwareArch)

if (ENABLE_LUAJIT_RANDOM_RA AND NOT IS_LUAJIT)
  message(FATAL_ERROR "Option ENABLE_LUAJIT_RANDOM_RA is LuaJIT-specific.")
endif()

if (USE_LUA AND NOT LUA_VERSION)
  set(LUA_VERSION "master")
endif()

if (USE_LUAJIT AND NOT LUA_VERSION)
  set(LUA_VERSION "v2.1")
endif()

if (USE_LUA)
  include(BuildLua)
  build_lua(${LUA_VERSION})
elseif (USE_LUAJIT)
  include(BuildLuaJIT)
  build_luajit(${LUA_VERSION})
  set(IS_LUAJIT TRUE)
elseif (LUA_INCLUDE_DIR AND LUA_LIBRARIES AND LUA_EXECUTABLE)
  message(STATUS "Lua library passed outside:")
  message(STATUS "LUA_INCLUDE_DIR: ${LUA_INCLUDE_DIR}")
  message(STATUS "LUA_LIBRARIES: ${LUA_LIBRARIES}")
  message(STATUS "LUA_EXECUTABLE: ${LUA_EXECUTABLE}")

  # When a path to a Lua library is passed outside, we should
  # mimic a real CMake library to don't break code that depends on
  # LUA_LIBRARIES.
  add_library(bundled-liblua STATIC IMPORTED GLOBAL)
  set_target_properties(bundled-liblua PROPERTIES
    IMPORTED_LOCATION ${LUA_LIBRARIES})
  set(LUA_LIBRARIES bundled-liblua)
else ()
  message(FATAL_ERROR "No Lua is specified.")
endif ()

message(STATUS "Found ${LUA_VERSION_STRING}")

if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR
   NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")
  message(FATAL_ERROR
      "\n"
      "Building is supported with Clang compiler only.\n"
      " $ rm -rf build\n"
      " $ cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -S . -B build\n"
      " $ cmake --build build --parallel\n"
      "\n")
endif()

find_package(Protobuf)
if (NOT Protobuf_FOUND)
    set(ENABLE_BUILD_PROTOBUF ON)
endif()

SetBuildParallelLevel(CMAKE_BUILD_PARALLEL_LEVEL)

if(ENABLE_COV)
    include(CodeCoverage)
endif()

enable_testing()

add_subdirectory(extra)
add_subdirectory(libluamut)
add_subdirectory(tests)
