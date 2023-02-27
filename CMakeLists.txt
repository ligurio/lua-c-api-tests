cmake_minimum_required(VERSION 3.10.2)

project(lua-c-api-tests
  LANGUAGES C CXX
  VERSION "1.0.0"
)

option(USE_LUA "Use PUC Rio Lua library" OFF)
option(USE_LUAJIT "Use LuaJIT library" OFF)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
set(CMAKE_INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_INCLUDE_PATH})

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
else ()
  message(FATAL_ERROR "No Lua is specified.")
endif ()

message(STATUS "Found ${LUA_VERSION_STRING}")

find_package(LLVM REQUIRED CONFIG)
if(${LLVM_PACKAGE_VERSION} VERSION_LESS 5.0.0)
  message(FATAL_ERROR "LLVM 5.0.0 or newer is required")
endif()

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

enable_testing()

add_subdirectory(tests)
