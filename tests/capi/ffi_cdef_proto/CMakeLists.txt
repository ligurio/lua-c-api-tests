set(test_name ffi_cdef_proto_test)

add_library(cdef-proto)

foreach(lib ${LPM_LIBRARIES})
    find_library(${lib} REQUIRED_FILES)
endforeach(lib)

protobuf_generate(LANGUAGE cpp
                  TARGET cdef-proto
                  PROTOS cdef.proto)

target_link_libraries(cdef-proto
                      ${PROTOBUF_LIBRARIES})

create_test(FILENAME ${test_name}
            SOURCES ffi_cdef_proto_test.cc cdef_print.cc
            LIBRARIES cdef-proto ${LPM_LIBRARIES})

target_include_directories(${test_name}
                           PUBLIC ${CMAKE_CURRENT_BINARY_DIR} ${LUA_INCLUDE_DIR})
add_dependencies(${test_name} ${LPM_LIBRARIES} cdef-proto)
