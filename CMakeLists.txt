cmake_minimum_required(VERSION 3.5.0)
include(cmake/extract_package_metadata.cmake)

extract_package_metadata(pkg)
project(${pkg_extracted_name} VERSION ${pkg_extracted_version})

include(cmake/cmake_tools.cmake)
include(cmake/cpack_tools.cmake)

install(FILES cmake/create_debian_changelog.py DESTINATION lib/cmake/${PROJECT_NAME}/ COMPONENT ${PROJECT_NAME})

configure_package(
  CFG_EXTRAS
    cmake/clang_tidy_tools.cmake
    cmake/cmake_tools.cmake
    cmake/code_coverage.cmake
    cmake/cpack_tools.cmake
    cmake/cppcheck_tools.cmake
    cmake/extract_package_metadata.cmake
    cmake/iwyu_tools.cmake
    cmake/sanitizers.cmake
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

  if(UNIX AND RICB_PACKAGE_SOURCE)
    if(NOT RICB_PACKAGE_SOURCE_UPLOAD)
      set(RICB_PACKAGE_SOURCE_UPLOAD OFF)
    endif()

    if(NOT RICB_PACKAGE_SOURCE_DISTRIBUTIONS)
      set(RICB_PACKAGE_SOURCE_DISTRIBUTIONS focal jammy)
    endif()

    if(NOT RICB_PACKAGE_SOURCE_DPUT_HOST)
      set(RICB_PACKAGE_SOURCE_DPUT_HOST ppa:levi-armstrong/tesseract-robotics)
    endif()

    if(NOT RICB_PACKAGE_SOURCE_DEBIAN_INCREMENT)
      set(RICB_PACKAGE_SOURCE_DEBIAN_INCREMENT 0)
    endif()

    cpack_debian_source_package(
      CHANGLELOG ${CMAKE_CURRENT_LIST_DIR}/CHANGELOG.rst
      UPLOAD ${RICB_PACKAGE_SOURCE_UPLOAD}
      DPUT_HOST ${RICB_PACKAGE_SOURCE_DPUT_HOST}
      DEBIAN_INCREMENT ${RICB_PACKAGE_SOURCE_DEBIAN_INCREMENT}
      DISTRIBUTIONS ${RICB_PACKAGE_SOURCE_DISTRIBUTIONS}
    )
  endif()
endif()
