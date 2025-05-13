macro(build_luajit LJ_VERSION)
    set(LJ_SOURCE_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/source)
    set(LJ_BINARY_DIR ${PROJECT_BINARY_DIR}/luajit-${LJ_VERSION}/work)

    set(CFLAGS ${CMAKE_C_FLAGS})
    if (ENABLE_LUA_ASSERT)
        set(CFLAGS "${CFLAGS} -DLUA_USE_ASSERT")
    endif (ENABLE_LUA_ASSERT)
    if (ENABLE_LUA_APICHECK)
        set(CFLAGS "${CFLAGS} -DLUA_USE_APICHECK")
    endif (ENABLE_LUA_APICHECK)

    set(CFLAGS "${CFLAGS} -fsanitize=fuzzer-no-link")
    set(LDFLAGS "-fsanitize=fuzzer-no-link")

    set(LUAJIT_BASEDIR ${PROJECT_SOURCE_DIR}/patches/)

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CFLAGS "${CFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
        set(LDFLAGS "${LDFLAGS} ${CMAKE_C_FLAGS_DEBUG}")
    endif (CMAKE_BUILD_TYPE STREQUAL "Debug")

    if (ENABLE_LUAJIT_RANDOM_RA)
        set(CFLAGS "${CFLAGS} -DLUAJIT_RANDOM_RA")
    endif (ENABLE_LUAJIT_RANDOM_RA)

    if (ENABLE_ASAN)
        set(CFLAGS "${CFLAGS} -fsanitize=address")
        set(CFLAGS "${CFLAGS} -DLUAJIT_USE_ASAN")
        set(CFLAGS "${CFLAGS} -DLUAJIT_USE_SYSMALLOC=1")
        set(LDFLAGS "${LDFLAGS} -fsanitize=address")
    endif (ENABLE_ASAN)

    if (ENABLE_UBSAN)
        string(JOIN "," NO_SANITIZE_FLAGS
            # Misaligned pseudo-pointers are used to determine
            # internal variable names inside the `for` cycle.
            alignment
            # Not interested in float cast overflow errors. These
            # overflows are handled by special checks after
            # `lj_num2int()`, etc.
            float-cast-overflow
            # NULL checking is disabled because this is not a UB
            # and raises lots of false-positive fails.
            null
            # Not interested in checking arithmetic with NULL.
            pointer-overflow
            # Shifts of negative numbers are widely used in
            # parsing ULEB, cdata arithmetic, vmevent hash
            # calculation, etc.
            shift-base
        )
        # GCC has no "function" UB check.
        if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
            string(JOIN "," NO_SANITIZE_FLAGS
                ${NO_SANITIZE_FLAGS}
                # Not interested in function type mismatch errors.
                function
            )
        endif()
        # Enable UndefinedBehaviorSanitizer support.
        # This flag enables all supported options (the
        # documentation on site is not correct about that moment,
        # unfortunately) except float-divide-by-zero. Floating
        # point division by zero behaviour is defined without
        # -ffast-math and uses the IEEE 754 standard on which all
        # NaN tagging is based.
        set(UBSAN_FLAGS "-fsanitize=undefined")
        set(UBSAN_FLAGS "-fno-sanitize-recover=undefined")
        # XXX: To get nicer stack traces in error messages.
        set(UBSAN_FLAGS "-fno-omit-frame-pointer")
        set(UBSAN_FLAGS "-fno-sanitize=${NO_SANITIZE_FLAGS}")
        set(CFLAGS "${CFLAGS} -DLUAJIT_USE_UBSAN")
        set(CFLAGS "${CFLAGS} ${UBSAN_FLAGS}")
        set(LDFLAGS "${LDFLAGS} ${UBSAN_FLAGS}")
    endif (ENABLE_UBSAN)

    if (ENABLE_COV)
        set(CFLAGS "${CFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
        set(LDFLAGS "${LDFLAGS} -fprofile-instr-generate -fprofile-arcs -fcoverage-mapping -ftest-coverage")
    endif (ENABLE_COV)

    if(ENABLE_LAPI_TESTS)
        # "relocation R_X86_64_PC32 against symbol `lua_isnumber'
        # can not be used when making a shared object; recompile
        # with -fPIC".
        set(CFLAGS "${CFLAGS} -fPIC")
        # CMake option LUAJIT_FRIENDLY_MODE in luzer requires
        # LUAJIT_ENABLE_CHECKHOOK.
        set(CFLAGS "${CFLAGS} -DLUAJIT_ENABLE_CHECKHOOK")
    endif()

    include(ExternalProject)

    set(LUA_LIBRARY ${LJ_SOURCE_DIR}/src/libluajit.a)
    set(LUA_EXECUTABLE ${LJ_SOURCE_DIR}/src/luajit)

    ExternalProject_Add(patched-luajit-${LJ_VERSION}
        GIT_REPOSITORY https://github.com/LuaJIT/LuaJIT
        GIT_TAG ${LJ_VERSION}
        GIT_PROGRESS TRUE
        GIT_SHALLOW FALSE
        GIT_REMOTE_UPDATE_STRATEGY REBASE

        SOURCE_DIR ${LJ_SOURCE_DIR}
        BINARY_DIR ${LJ_BINARY_DIR}/luajit-${LJ_VERSION}
        DOWNLOAD_DIR ${LJ_BINARY_DIR}
        TMP_DIR ${LJ_BINARY_DIR}/tmp
        STAMP_DIR ${LJ_BINARY_DIR}/stamp

        PATCH_COMMAND git reset --hard && cd <SOURCE_DIR> &&
                      patch -p1 -i ${LUAJIT_BASEDIR}/luajit-v2.1.patch &&
                      patch -p1 -i ${LUAJIT_BASEDIR}/luajit-dmalloc-asan_instr-v2.1.patch
        CONFIGURE_COMMAND ""
        BUILD_COMMAND cd <SOURCE_DIR> && make -j CC=${CMAKE_C_COMPILER}
                                                 CFLAGS=${CFLAGS}
                                                 LDFLAGS=${LDFLAGS}
                                                 HOST_CFLAGS=-fno-sanitize=undefined
                                                 -C src
        INSTALL_COMMAND ""

        BUILD_BYPRODUCTS ${LUA_LIBRARY} ${LUA_EXECUTABLE}
    )

    add_library(bundled-liblua STATIC IMPORTED GLOBAL)
    set_target_properties(bundled-liblua PROPERTIES
      IMPORTED_LOCATION ${LUA_LIBRARY})
    add_dependencies(bundled-liblua patched-luajit-${LJ_VERSION})

    set(LUA_LIBRARIES bundled-liblua)
    set(LUA_INCLUDE_DIR ${LJ_SOURCE_DIR}/src/)
    set(LUA_VERSION_STRING "LuaJIT ${LJ_VERSION}")

    unset(LJ_SOURCE_DIR)
    unset(LJ_BINARY_DIR)
endmacro(build_luajit)
