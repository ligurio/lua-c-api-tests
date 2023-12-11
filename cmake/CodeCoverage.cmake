find_program(GCOVR gcovr)
find_program(LLVM_COV llvm-cov)

set(COVERAGE_DIR "${PROJECT_BINARY_DIR}/coverage")
set(COVERAGE_HTML_REPORT "${COVERAGE_DIR}/report.html")
set(COVERAGE_XML_REPORT "${COVERAGE_DIR}/report.xml")

set(target_name "coverage-report")
if(NOT GCOVR OR NOT LLVM_COV)
  set(MSG "${target_name} is a dummy target")
  add_custom_target(${target_name}
    COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --red ${MSG}
  )
  message(WARNING "Either `gcovr' or `llvm-cov` not found, "
                  "so ${target_name} target is dummy.")
  return()
endif()

# See https://gcovr.com/en/stable/manpage.html.
set(GCOVR_OPTIONS
  --branches
  --cobertura ${COVERAGE_XML_REPORT}
  --decisions
  --gcov-executable "llvm-cov gcov"
  --html
  --html-details
  --html-title "Code Coverage Report"
  -j ${CMAKE_BUILD_PARALLEL_LEVEL}
  --output ${COVERAGE_HTML_REPORT}
  --print-summary
  --root ${LUA_SOURCE_DIR}
  --sort-percentage
)

if(USE_LUA)
  set(GCOVR_OPTIONS ${GCOVR_OPTIONS} --object-directory ${LUA_SOURCE_DIR})
endif ()

if(USE_LUAJIT)
  # Exclude DynASM files, that contain a low-level VM code for CPUs.
  set(GCOVR_OPTIONS ${GCOVR_OPTIONS} --exclude ".*\.dasc")
  # Exclude buildvm source code, it's a project's build infrastructure.
  set(GCOVR_OPTIONS ${GCOVR_OPTIONS} --exclude ".*/host/")
  set(GCOVR_OPTIONS ${GCOVR_OPTIONS} --object-directory ${LUA_SOURCE_DIR}/src)
endif (USE_LUAJIT)

file(MAKE_DIRECTORY ${COVERAGE_DIR})
add_custom_target(${target_name})
add_custom_command(TARGET ${target_name}
  COMMENT "Building coverage report"
  COMMAND ${GCOVR} ${GCOVR_OPTIONS}
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

message(STATUS "Code coverage HTML report: ${COVERAGE_HTML_REPORT}")
message(STATUS "Code coverage XML report: ${COVERAGE_XML_REPORT}")
