set(LUZER_DIR ${PROJECT_BINARY_DIR}/luzer)
set(LUZER_BUILD_DIR ${LUZER_DIR}/build)
set(LUZER_LIBRARY_PATH ${LUZER_BUILD_DIR}/luzer)
list(APPEND LUZER_LIBRARIES
    ${LUZER_LIBRARY_PATH}/luzer/luzer.so
    ${LUZER_LIBRARY_PATH}/luzer/libcustom_mutator.so
)

include(ExternalProject)

get_target_property(LUA_LIBRARIES_LOCATION ${LUA_LIBRARIES} LOCATION)

list(APPEND LUZER_CMAKE_FLAGS
    "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
    "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    "-DLUA_INCLUDE_DIR=${LUA_INCLUDE_DIR}"
    "-DLUA_LIBRARIES=${LUA_LIBRARIES_LOCATION}"
)
# Prevents an error on loading `luzer_impl.so` due to undefined
# symbol `llvm_gcda_summary_info`.
if(ENABLE_COV)
  list(APPEND LUZER_CMAKE_FLAGS
      -DCMAKE_C_FLAGS=-fprofile-instr-generate
      -DCMAKE_CXX_FLAGS=-fprofile-instr-generate
  )
endif()
if(USE_LUAJIT)
    list(APPEND LUZER_CMAKE_FLAGS
        "-DLUAJIT_FRIENDLY_MODE=ON"
        "-DLUA_HAS_JIT=ON"
    )
endif()

ExternalProject_Add(bundled-luzer
    GIT_REPOSITORY https://github.com/ligurio/luzer
    GIT_TAG 3f4eb03b4ff7596855a0aaf45aa557f61b25ddb2
    GIT_PROGRESS TRUE
    GIT_SHALLOW FALSE
    SOURCE_DIR ${LUZER_DIR}/source
    BINARY_DIR ${LUZER_BUILD_DIR}
    TMP_DIR ${LUZER_DIR}/tmp
    STAMP_DIR ${LUZER_DIR}/stamp
    CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -B <BINARY_DIR> -S <SOURCE_DIR>
            -G ${CMAKE_GENERATOR} ${LUZER_CMAKE_FLAGS}
    BUILD_COMMAND cd <BINARY_DIR> && ${CMAKE_MAKE_PROGRAM}
    INSTALL_COMMAND ""
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    BUILD_BYPRODUCTS ${LUZER_LIBRARIES}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

add_library(luzer-library STATIC IMPORTED GLOBAL)
set_target_properties(luzer-library PROPERTIES
  IMPORTED_LOCATION "${LUZER_LIBRARIES}")
add_dependencies(luzer-library bundled-luzer)
add_dependencies(bundled-luzer bundled-liblua)

set(LUZER_LUA_PATH ${LUZER_DIR}/source/?/init.lua)
set(LUZER_LUA_PATH ${LUZER_LUA_PATH} PARENT_SCOPE)

set(LUZER_LUA_CPATH ${LUZER_LIBRARY_PATH}/?${CMAKE_SHARED_LIBRARY_SUFFIX})
set(LUZER_LUA_CPATH ${LUZER_LUA_CPATH} PARENT_SCOPE)

set(LUZER_LIBRARY luzer-library PARENT_SCOPE)

unset(LUZER_DIR)
unset(LUZER_BUILD_DIR)
