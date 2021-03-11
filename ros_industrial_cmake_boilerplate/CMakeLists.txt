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

if (RICB_PACKAGE)
  set(CPACK_PACKAGE_VENDOR "ROS-Industrial")
  set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_LIST_DIR}/../LICENSE)
  set(CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_LIST_DIR}/../README.rst)

  if (UNIX)
    set(CPACK_GENERATOR "DEB;TXZ")
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}_${CMAKE_SYSTEM_PROCESSOR}_linux_${pkg_extracted_version}")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate>)
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${pkg_extracted_description})
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS=ON)
  elseif(WIN32)
    set(CPACK_GENERATOR "NuGet;TXZ")
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}_${CMAKE_SYSTEM_PROCESSOR}_windows_${pkg_extracted_version}")
    set(CPACK_NUGET_PACKAGE_NAME "${PROJECT_NAME}_${CMAKE_SYSTEM_PROCESSOR}_windows")
    set(CPACK_NUGET_PACKAGE_DESCRIPTION ${pkg_extracted_description})
  endif()
  include(CPack)
endif()
