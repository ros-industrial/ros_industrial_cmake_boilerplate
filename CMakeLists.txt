cmake_minimum_required(VERSION 3.5.0)
project(cmake_common_scripts VERSION 0.1.0 LANGUAGES CXX)
include(cmake/cmake_tools.cmake)
include(cmake/code_coverage.cmake)

#add_library(${PROJECT_NAME} INTERFACE)
#target_link_libraries(${PROJECT_NAME} INTERFACE)
#target_include_directories(${PROJECT_NAME} INTERFACE
#    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
#    "$<INSTALL_INTERFACE:include>")

configure_package()

install(FILES
  "${CMAKE_CURRENT_LIST_DIR}/cmake/cmake_tools.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/cmake/code_coverage.cmake"
  DESTINATION lib/cmake/${PROJECT_NAME})

