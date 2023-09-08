macro(SetProtobufDirs)
    # Part of protobuf.cmake moved here due to build problems of
    # libprotobuf-mutator with separate protobuf installation.

    # FindProtobuf is present in a newer versions of CMake,
    # see https://cmake.org/cmake/help/latest/module/FindProtobuf.html.
    # We only need protobuf_generate_cpp from FindProtobuf, and the rest will
    # be downloaded with LPM.
    include (FindProtobuf)

    set(PROTOBUF_TARGET external.protobuf)
    set(PROTOBUF_INSTALL_DIR ${LPM_INSTALL_DIR}/src/${LPM_TARGET}-build/${PROTOBUF_TARGET})

    set(PROTOBUF_INCLUDE_DIRS ${PROTOBUF_INSTALL_DIR}/include)
    include_directories(${PROTOBUF_INCLUDE_DIRS})

    set(PROTOBUF_LIBRARIES protobufd)

    foreach(lib ${PROTOBUF_LIBRARIES})
        set(LIB_PROTOBUF_PATH ${PROTOBUF_INSTALL_DIR}/lib/lib${lib}.a)
        list(APPEND PROTOBUF_BUILD_BYPRODUCTS ${LIB_PROTOBUF_PATH})

        add_library(${lib} STATIC IMPORTED)
        set_property(TARGET ${lib} PROPERTY IMPORTED_LOCATION
                     ${LIB_PROTOBUF_PATH})
        add_dependencies(${lib} ${PROTOBUF_TARGET} ${LPM_TARGET})
    endforeach(lib)

    set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_INSTALL_DIR}/bin/protoc)
    list(APPEND PROTOBUF_BUILD_BYPRODUCTS ${PROTOBUF_PROTOC_EXECUTABLE})

    if(${CMAKE_VERSION} VERSION_LESS "3.10.0")
        set(PROTOBUF_PROTOC_TARGET protoc)
    else()
        set(PROTOBUF_PROTOC_TARGET protobuf::protoc)
    endif()

    if(NOT TARGET ${PROTOBUF_PROTOC_TARGET})
        add_executable(${PROTOBUF_PROTOC_TARGET} IMPORTED)
    endif()
    set_property(TARGET ${PROTOBUF_PROTOC_TARGET} PROPERTY IMPORTED_LOCATION
                 ${PROTOBUF_PROTOC_EXECUTABLE})
    add_dependencies(${PROTOBUF_PROTOC_TARGET} ${PROTOBUF_TARGET} ${LPM_TARGET})

    # CMake 3.7 uses Protobuf_ when 3.5 PROTOBUF_ prefixes.
    set(Protobuf_INCLUDE_DIRS ${PROTOBUF_INCLUDE_DIRS})
    set(Protobuf_LIBRARIES ${PROTOBUF_LIBRARIES})
    set(Protobuf_PROTOC_EXECUTABLE ${PROTOBUF_PROTOC_EXECUTABLE})
endmacro()
