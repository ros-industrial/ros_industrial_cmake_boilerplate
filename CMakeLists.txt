cmake_minimum_required(VERSION 3.5.0)
include(cmake/extract_package_metadata.cmake)

extract_package_metadata(pkg)
project(${pkg_extracted_name} VERSION ${pkg_extracted_version})

include(cmake/cmake_tools.cmake)

configure_package(
  CFG_EXTRAS
    cmake/cmake_tools.cmake
    cmake/code_coverage.cmake
    cmake/extract_package_metadata.cmake
)

install(DIRECTORY cmake DESTINATION lib/cmake/${PROJECT_NAME})

if (RICB_PACKAGE)
  cpack(
    VERSION
    ${pkg_extracted_version}
    MAINTAINER
    <https://github.com/tesseract-robotics/ros_industrial_cmake_boilerplate>
    VENDOR
    "ROS-Industrial"
    DESCRIPTION
    "${PROJECT_NAME}"
    LICENSE_FILE
    ${CMAKE_CURRENT_LIST_DIR}/../LICENSE
    README_FILE
    ${CMAKE_CURRENT_LIST_DIR}/../README.rst
  )
endif()
