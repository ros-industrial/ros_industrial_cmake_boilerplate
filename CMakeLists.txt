cmake_minimum_required(VERSION 3.5.0)
include(cmake/extract_package_metadata.cmake)

extract_package_metadata(pkg)
project(${pkg_extracted_name} VERSION ${pkg_extracted_version})

include(cmake/cmake_tools.cmake)

install(FILES cmake/create_debian_changelog.py DESTINATION lib/cmake/${PROJECT_NAME}/ COMPONENT ${PROJECT_NAME})

configure_package(
  CFG_EXTRAS
    cmake/cmake_tools.cmake
    cmake/code_coverage.cmake
    cmake/cpack_tools.cmake
    cmake/extract_package_metadata.cmake
)

if (RICB_PACKAGE)
  cpack(
    VERSION ${pkg_extracted_version}
    MAINTAINER_NAME ${pkg_extracted_maintainer_name}
    MAINTAINER_EMAIL ${pkg_extracted_maintainer_email}
    VENDOR "ROS-Industrial"
    DESCRIPTION "${PROJECT_NAME}"
    LICENSE_FILE ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    README_FILE ${CMAKE_CURRENT_LIST_DIR}/README.rst
  )
endif()
