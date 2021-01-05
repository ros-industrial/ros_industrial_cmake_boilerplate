cmake_minimum_required(VERSION 3.5.0)
include(cmake/extract_package_metadata.cmake)

extract_package_metadata(pkg)
project(${pkg_extracted_name} VERSION ${pkg_extracted_version})

include(cmake/cmake_tools.cmake)

configure_package()

install(FILES
  "${CMAKE_CURRENT_LIST_DIR}/cmake/cmake_tools.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/cmake/code_coverage.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/cmake/extract_package_metadata.cmake"
  DESTINATION lib/cmake/${PROJECT_NAME})

