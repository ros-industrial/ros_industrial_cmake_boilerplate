## -*- mode:cmake; coding:utf-8; -*-
# Copyright (c) 2010 Daniel Pfeifer <daniel@pfeifer-mail.de>
# Changes Copyright (c) 2011 2012 Rüdiger Sonderfeld <ruediger@c-plusplus.de>
#
# cpack_tools.cmake is free software. It comes without any warranty,
# to the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
#
##
# Documentation
#
# This CMake module uploads a project to a PPA.  It creates all the files
# necessary (similar to CPack) and uses debuild(1) and dput(1) to create the
# package and upload it to a PPA.  A PPA is a Personal Package Archive and can
# be used by Debian/Ubuntu or other apt/deb based distributions to install and
# update packages from a remote repository.
# Canonicals Launchpad (http://launchpad.net) is usually used to host PPAs.
# See https://help.launchpad.net/Packaging/PPA for further information
# about PPAs.
#
# UploadPPA.cmake uses similar settings to CPack and the CPack DEB Generator.
# Additionally the following variables are used
#

find_program(DEBUILD_EXECUTABLE debuild)
find_program(DPUT_EXECUTABLE dput)
set(RICB_CPACK_TOOLS_DIR ${CMAKE_CURRENT_LIST_DIR})

# Configure package for cpack which does not leverage components
# One Value Args:
#   * VERSION          - The package version
#   * MAINTAINER_NAME  - The package maintainer name
#   * MAINTAINER_EMAIL - The package maintainer email
#   * VENDOR           - The package vender
#   * DESCRIPTION      - The package description
#   * LICENSE_FILE     - The package license file
#   * README_FILE      - The package readme
#   * PACKAGE_PREFIX   - The package prefix applied to all cpack generated files
# Multi Value Args:
#   * LINUX_DEPENDS     - The linux dependencies required via apt install
#   * WINDOWS_DEPENDS   - The windows dependencies required via nuget install
macro(cpack)
  set(oneValueArgs
      VERSION
      MAINTAINER_NAME
      MAINTAINER_EMAIL
      VENDOR
      DESCRIPTION
      LICENSE_FILE
      README_FILE
      PACKAGE_PREFIX)
  set(multiValueArgs LINUX_DEPENDS WINDOWS_DEPENDS)
  cmake_parse_arguments(
    ARG
    ""
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  set(CPACK_PACKAGE_VENDOR ${ARG_VENDOR})
  set(CPACK_RESOURCE_FILE_LICENSE ${ARG_LICENSE_FILE})
  set(CPACK_RESOURCE_FILE_README ${ARG_README_FILE})
  string(
    REPLACE "_"
            "-"
            PACKAGE_NAME
            ${PROJECT_NAME})
  if(UNIX)
    set(CPACK_GENERATOR "DEB;TXZ")

    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
      set(DEB_ARCH "amd64")
    else()
      set(DEB_ARCH ${CMAKE_SYSTEM_PROCESSOR})
    endif()

    set(CPACK_PACKAGE_FILE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}_${DEB_ARCH}_linux_${ARG_VERSION}")
    set(CPACK_DEBIAN_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}")
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${DEB_ARCH})
    if(NOT CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME)
      set(CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME ${ARG_MAINTAINER_NAME})
    endif()
    if(NOT CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL)
      set(CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL ${ARG_MAINTAINER_EMAIL})
    endif()
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME} <${CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL}>")
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${ARG_DESCRIPTION})
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS=ON)

    SET(CPACK_DEBIAN_PACKAGE_SECTION "devel")
    SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")

    string(
      REPLACE ";"
              ", "
              CPACK_DEBIAN_PACKAGE_DEPENDS
              "${ARG_LINUX_DEPENDS}")
  elseif(WIN32)
    set(CPACK_GENERATOR "NuGet;TXZ")
    set(CPACK_PACKAGE_FILE_NAME
        "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}_${CMAKE_SYSTEM_PROCESSOR}_windows_${ARG_VERSION}")
    set(CPACK_NUGET_PACKAGE_NAME
        "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}_${CMAKE_SYSTEM_PROCESSOR}_windows")
    set(CPACK_NUGET_PACKAGE_DESCRIPTION ${ARG_DESCRIPTION})
    string(
      REPLACE ";"
              ", "
              CPACK_NUGET_PACKAGE_DEPENDENCIES
              "${ARG_WINDOWS_DEPENDS}")
  endif()
  include(CPack)
endmacro()

# Configure package leveraging components for cpack
# One Value Args:
#   * VERSION          - The package version
#   * MAINTAINER_NAME  - The package maintainer name
#   * MAINTAINER_EMAIL - The package maintainer email
#   * VENDOR           - The package vender
#   * DESCRIPTION      - The package description
#   * LICENSE_FILE     - The package license file
#   * README_FILE      - The package readme
#   * PACKAGE_PREFIX   - The package prefix applied to all cpack generated files
# Multi Value Args:
#   * COMPONENT_DEPENDS - The component dependencies required from this package
macro(cpack_component_package)
  set(oneValueArgs
      VERSION
      MAINTAINER_NAME
      MAINTAINER_EMAIL
      VENDOR
      DESCRIPTION
      LICENSE_FILE
      README_FILE
      PACKAGE_PREFIX)
  set(multiValueArgs COMPONENT_DEPENDS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/cpack_metapackage "")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/cpack_metapackage DESTINATION share/${PROJECT_NAME}/ COMPONENT ${PROJECT_NAME})

  set(CPACK_PACKAGE_VENDOR ${ARG_VENDOR})
  set(CPACK_RESOURCE_FILE_LICENSE ${ARG_LICENSE_FILE})
  set(CPACK_RESOURCE_FILE_README ${ARG_README_FILE})

  string(
    REPLACE "_"
            "-"
            PACKAGE_NAME
            ${PROJECT_NAME})

  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

  if(UNIX)
    set(CPACK_GENERATOR "DEB;TXZ")

    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
      set(DEB_ARCH "amd64")
    else()
      set(DEB_ARCH ${CMAKE_SYSTEM_PROCESSOR})
    endif()

    set(CPACK_DEBIAN_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}")
    set(CPACK_DEB_COMPONENT_INSTALL ON)
    set(CPACK_DEBIAN_ENABLE_COMPONENT_DEPENDS ON)
    if(NOT CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME)
      set(CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME ${ARG_MAINTAINER_NAME})
    endif()
    if(NOT CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL)
      set(CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL ${ARG_MAINTAINER_EMAIL})
    endif()
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME} <${CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL}>")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS=ON)

    SET(CPACK_DEBIAN_PACKAGE_SECTION "devel")
    SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")

    set(CPACK_DEBIAN_${PROJECT_NAME_UPPER}_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}")
    set(CPACK_DEBIAN_${PROJECT_NAME_UPPER}_FILE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}_${DEB_ARCH}_linux_${ARG_VERSION}.deb")
    set(CPACK_DEBIAN_${PROJECT_NAME_UPPER}_PACKAGE_SHLIBDEPS=ON)
    set(CPACK_DEBIAN_${PROJECT_NAME_UPPER}_PACKAGE_ARCHITECTURE ${DEB_ARCH})
    set(CPACK_DEBIAN_${PROJECT_NAME_UPPER}_DESCRIPTION ${ARG_DESCRIPTION})
  elseif(WIN32)
    set(CPACK_NUGET_COMPONENT_INSTALL ON)
    set(CPACK_GENERATOR "NuGet;TXZ")
    set(CPACK_NUGET_${PROJECT_NAME_UPPER}_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}")
    set(CPACK_NUGET_${PROJECT_NAME_UPPER}_FILE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}_${CMAKE_SYSTEM_PROCESSOR}_windows_${ARG_VERSION}.nupkg")
  endif()

  set(CPACK_COMPONENT_${PROJECT_NAME_UPPER}_DEPENDS ${ARG_COMPONENT_DEPENDS})

  include(CPack)
endmacro()

# Configure components for cpack
# One Value Args:
#   * COMPONENT      - The component name
#   * VERSION        - The package version
#   * DESCRIPTION    - The package description
#   * PACKAGE_PREFIX - The package prefix applied to all cpack generated files
# Multi Value Args:
#   * LINUX_DEPENDS     - The linux dependencies required via apt install
#   * WINDOWS_DEPENDS   - The windows dependencies required via nuget install
#   * COMPONENT_DEPENDS - The component dependencies required from this package
macro(cpack_component)
  set(oneValueArgs COMPONENT VERSION DESCRIPTION PACKAGE_PREFIX)
  set(multiValueArgs LINUX_DEPENDS WINDOWS_DEPENDS COMPONENT_DEPENDS)
  cmake_parse_arguments(
    ARG
    ""
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  string(
    REPLACE "_"
            "-"
            PACKAGE_NAME
            ${PROJECT_NAME})

  string(TOUPPER ${ARG_COMPONENT} COMPONENT_UPPER)
  string(TOLOWER ${ARG_COMPONENT} COMPONENT_LOWER)

  if(UNIX)
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
      set(DEB_ARCH "amd64")
    else()
      set(DEB_ARCH ${CMAKE_SYSTEM_PROCESSOR})
    endif()

    string(
      REPLACE ";"
              ", "
              PACKAGE_DEPENDS
              "${ARG_LINUX_DEPENDS}")

    set(CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}-${COMPONENT_LOWER}" PARENT_SCOPE)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_FILE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}-${COMPONENT_LOWER}_${DEB_ARCH}_linux_${ARG_VERSION}.deb" PARENT_SCOPE)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_SHLIBDEPS=ON PARENT_SCOPE)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_ARCHITECTURE ${DEB_ARCH} PARENT_SCOPE)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_DESCRIPTION ${ARG_DESCRIPTION} PARENT_SCOPE)
    set(CPACK_DEBIAN_${COMPONENT_UPPER}_PACKAGE_DEPENDS ${PACKAGE_DEPENDS} PARENT_SCOPE)
  elseif(WIN32)
    string(
      REPLACE ";"
              ", "
              PACKAGE_DEPENDS
              "${ARG_WINDOWS_DEPENDS}")

    set(CPACK_NUGET_${COMPONENT_UPPER}_PACKAGE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}-${COMPONENT_LOWER}" PARENT_SCOPE)
    set(CPACK_NUGET_${COMPONENT_UPPER}_FILE_NAME "${ARG_PACKAGE_PREFIX}${PACKAGE_NAME}-${COMPONENT_LOWER}_${CMAKE_SYSTEM_PROCESSOR}_windows_${ARG_VERSION}.nupkg" PARENT_SCOPE)
    set(CPACK_NUGET_${COMPONENT_UPPER}_DESCRIPTION ${ARG_DESCRIPTION} PARENT_SCOPE)
    set(CPACK_NUGET_${COMPONENT_UPPER}_PACKAGE_DEPENDENCIES ${PACKAGE_DEPENDS} PARENT_SCOPE)
  endif()

  set(CPACK_COMPONENT_${COMPONENT_UPPER}_DEPENDS ${ARG_COMPONENT_DEPENDS} PARENT_SCOPE)

endmacro()


# Create debian source package leveraging cpack for upload to ppa like launchpad.net
# One Value Args:
#   * CHANGLELOG (Required)         - The file path to the package CHANGELOG.rst
#   * PACKAGE_PREFIX (Optional)     - The package prefix applied to all cpack generated files
#   * UPLOAD (Optional)             - Indicate if it should be uploaded to ppa
#   * DEBIAN_INCREMENT              - The debian increment to be used, default is zero
#   * DPUT_HOST (Optional/Required) - The ppa to upload to. Only required if UPLOAD is enabled
#   * DPUT_CONFIG_IN (Optional)     - The dput config.in file. If not provide one is created.
# Multi Value Args:
#   * DISTRIBUTIONS - The linux distrabution to deploy
#
# Leveraged CPack Variable: When using the cpack macros above these are automatically set
#    * CPACK_PACKAGE_DESCRIPTION (Required)
#    * CPACK_PACKAGE_VERSION (Required)
#    * CPACK_PACKAGE_DESCRIPTION_FILE (Optional)
#    * CPACK_SOURCE_IGNORE_FILES (Optional)
#
#    * CPACK_DEBIAN_PACKAGE_NAME (Required)
#    * CPACK_DEBIAN_PACKAGE_SECTION (Required)
#    * CPACK_DEBIAN_PACKAGE_PRIORITY (Required)
#    * CPACK_DEBIAN_PACKAGE_MAINTAINER (Required)
#    * CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME (Required)
#    * CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL (Required)
#    * CPACK_DEBIAN_PACKAGE_ARCHITECTURE (Required)
#    * CPACK_DEBIAN_PACKAGE_DESCRIPTION (Optional)
#    * CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS (Optional)
#    * CPACK_DEBIAN_PACKAGE_DEPENDS (Optional)
#    * CPACK_DEBIAN_PACKAGE_HOMEPAGE (Optional)
#
#    * CPACK_COMPONENT_<COMPONENT>_DEPENDS (Reqired if components exist and enabled)
#    * CPACK_DEBIAN_<COMPONENT>_PACKAGE_ARCHITECTURE (Reqired if components exist and enabled)
#    * CPACK_DEBIAN_<COMPONENT>_DESCRIPTION (Reqired if components exist and enabled)
#
macro(cpack_debian_source_package)
  set(oneValueArgs PACKAGE_PREFIX CHANGLELOG UPLOAD DEBIAN_INCREMENT DPUT_HOST DPUT_CONFIG_IN)
  set(multiValueArgs DISTRIBUTIONS)
  cmake_parse_arguments(
    ARG
    ""
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN})

  if(NOT DEBUILD_EXECUTABLE OR NOT DPUT_EXECUTABLE)
    message(WARNING "Debuild or dput not installed, please run sudo apt-get install devscripts")
    return()
  endif(NOT DEBUILD_EXECUTABLE OR NOT DPUT_EXECUTABLE)


  if(NOT ARG_DISTRIBUTIONS)
    execute_process(
        COMMAND lsb_release -cs
        OUTPUT_VARIABLE DISTRI
        OUTPUT_STRIP_TRAILING_WHITESPACE)
        set(ARG_DISTRIBUTIONS ${DISTRI})
        message(STATUS "ARG_DISTRIBUTIONS NOT provided, so using system settings : ${DISTRI}")
  endif()

  foreach(DISTRI ${ARG_DISTRIBUTIONS})
    message(STATUS "Building for ${DISTRI}")

    if(NOT CPACK_PACKAGE_DESCRIPTION AND EXISTS ${CPACK_PACKAGE_DESCRIPTION_FILE})
      file(STRINGS ${CPACK_PACKAGE_DESCRIPTION_FILE} DESC_LINES)
      foreach(LINE ${DESC_LINES})
        set(deb_long_description "${deb_long_description} ${LINE}\n")
      endforeach(LINE ${DESC_LINES})
    else()
      # add space before each line
      if(NOT CPACK_PACKAGE_DESCRIPTION)
        string(REPLACE "\n" "\n " deb_long_description " ${CPACK_PACKAGE_DESCRIPTION}")
      endif()
    endif()

    if(NOT ARG_DEBIAN_INCREMENT AND NOT ARG_DISTRIBUTIONS)
      message(WARNING "Variable PPA_DEBIAN_VERSION not set! Building 'native' package!")
      set(DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
    else()
      if(NOT ARG_DEBIAN_INCREMENT)
        set(ARG_DEBIAN_INCREMENT 0)
      endif()
      set(DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}-${ARG_DEBIAN_INCREMENT}${DISTRI}")
    endif()

    message(STATUS "Debian version: ${DEBIAN_PACKAGE_VERSION}")

    set(DEBIAN_SOURCE_DIR ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/${CPACK_DEBIAN_PACKAGE_NAME}_${DEBIAN_PACKAGE_VERSION})

    ##############################################################################
    # debian/control

    set(debian_control ${DEBIAN_SOURCE_DIR}/debian/control)
    list(APPEND CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS "cmake" "debhelper (>= 7.0.50)")
    list(REMOVE_DUPLICATES CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS)
    list(SORT CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS)
    string(REPLACE ";" ", " build_depends "${CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS}")
    file(WRITE ${debian_control}
      "Source: ${CPACK_DEBIAN_PACKAGE_NAME}\n"
      "Section: ${CPACK_DEBIAN_PACKAGE_SECTION}\n"
      "Priority: ${CPACK_DEBIAN_PACKAGE_PRIORITY}\n"
      "Maintainer: ${CPACK_DEBIAN_PACKAGE_MAINTAINER}\n"
      "Build-Depends: ${build_depends}\n"
      "Standards-Version: 3.9.7\n"
      "Homepage: ${CPACK_DEBIAN_PACKAGE_HOMEPAGE}\n"
    )

    if(NOT CPACK_COMPONENTS_ALL)
      string(REPLACE ";" ", " bin_depends "${CPACK_DEBIAN_PACKAGE_DEPENDS}")
      if(bin_depends)
        set(DEPENDS "${bin_depends}, \${shlibs:Depends}, \${misc:Depends}")
      else()
        set(DEPENDS "\${shlibs:Depends}, \${misc:Depends}")
      endif()
      file(APPEND ${debian_control}
        "\n"
        "Package: ${CPACK_DEBIAN_PACKAGE_NAME}\n"
        "Architecture: ${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}\n"
        "Depends: ${DEPENDS}\n"
        "Description: ${CPACK_DEBIAN_PACKAGE_DESCRIPTION}\n"
        "${deb_long_description}"
      )

      file(APPEND ${debian_control}
        "\n\n"
        "Package: ${CPACK_DEBIAN_PACKAGE_NAME}-dbg\n"
        "Priority: extra\n"
        "Section: debug\n"
        "Architecture: any\n"
        "Depends: ${CPACK_DEBIAN_PACKAGE_NAME} (= \${binary:Version}), \${shlibs:Depends}, \${misc:Depends}\n"
        "Description: ${CPACK_DEBIAN_PACKAGE_DESCRIPTION}\n"
        "${deb_long_description}"
        "\n"
      )
    endif()

    foreach(COMPONENT ${CPACK_COMPONENTS_ALL})
      string(TOUPPER ${COMPONENT} UPPER_COMPONENT)
      unset(DEPENDS)
      foreach(DEP ${CPACK_COMPONENT_${UPPER_COMPONENT}_DEPENDS})
        if (DEPENDS)
          set(DEPENDS "${DEPENDS}, ${ARG_PACKAGE_PREFIX}${CPACK_DEBIAN_PACKAGE_NAME}-${DEP}")
        else()
          set(DEPENDS "${ARG_PACKAGE_PREFIX}${CPACK_DEBIAN_PACKAGE_NAME}-${DEP}")
        endif()
      endforeach(DEP ${CPACK_COMPONENT_${UPPER_COMPONENT}_DEPENDS})

      if(PROJECT_NAME STREQUAL COMPONENT)
        set(COMPONENT_PACKAGE_NAME ${CPACK_DEBIAN_PACKAGE_NAME})
      else()
        set(COMPONENT_PACKAGE_NAME ${CPACK_DEBIAN_PACKAGE_NAME}-${COMPONENT})
        if(DEPENDS)
          set(DEPENDS "${DEPENDS}, \${shlibs:Depends}, \${misc:Depends}")
        else()
          set(DEPENDS "\${shlibs:Depends}, \${misc:Depends}")
        endif()
      endif()

      file(APPEND ${debian_control} "\n"
        "Package: ${COMPONENT_PACKAGE_NAME}\n"
        "Architecture: ${CPACK_DEBIAN_${UPPER_COMPONENT}_PACKAGE_ARCHITECTURE}\n"
        "Depends: ${DEPENDS}\n"
        "Description: ${CPACK_DEBIAN_${UPPER_COMPONENT}_DESCRIPTION}\n"
        "${deb_long_description}"
        "\n"
        )
    endforeach(COMPONENT ${CPACK_COMPONENTS_ALL})

    ##############################################################################
    # debian/copyright
    set(debian_copyright ${DEBIAN_SOURCE_DIR}/debian/copyright)
    configure_file(${CPACK_RESOURCE_FILE_LICENSE} ${debian_copyright} COPYONLY)

    ##############################################################################
    # debian/rules
    set(debian_rules ${DEBIAN_SOURCE_DIR}/debian/rules)

    file(WRITE ${debian_rules}
        "#!/usr/bin/make -f\n"
        "\nexport DH_VERBOSE=1"
        "\n\n%:\n"
        "\tdh  $@ --buildsystem=cmake\n"
        "\noverride_dh_auto_configure:\n"
        "\tDESTDIR=\"$(CURDIR)/debian/${CPACK_DEBIAN_PACKAGE_NAME}\" dh_auto_configure -- -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=ON -DPACKAGE_TGZ=OFF"
        "\n\noverride_dh_auto_install:\n"
        "\tdh_auto_install --destdir=\"$(CURDIR)/debian/${CPACK_DEBIAN_PACKAGE_NAME}\" --buildsystem=cmake"
        "\n\noverride_dh_strip:\n"
        "\tdh_strip --dbg-package=${CPACK_DEBIAN_PACKAGE_NAME}-dbg"
    )

    execute_process(COMMAND chmod +x ${debian_rules})

    ##############################################################################
    # debian/compat
    file(WRITE ${DEBIAN_SOURCE_DIR}/debian/compat "7")

    ##############################################################################
    # debian/source/format
    file(WRITE ${DEBIAN_SOURCE_DIR}/debian/source/format "3.0 (native)")

    ##############################################################################
    # debian/changelog
    set(debian_changelog ${DEBIAN_SOURCE_DIR}/debian/changelog)
    if(NOT CPACK_DEBIAN_RESOURCE_FILE_CHANGELOG)
      set(CPACK_DEBIAN_RESOURCE_FILE_CHANGELOG ${CMAKE_SOURCE_DIR}/debian/changelog)
      execute_process(
        COMMAND
          python3
          create_debian_changelog.py
          "${CPACK_DEBIAN_PACKAGE_NAME}"
          "${CPACK_PACKAGE_VERSION}"
          "${CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME}"
          "${CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL}"
          "${DISTRI}"
          "${ARG_DEBIAN_INCREMENT}"
          "${ARG_CHANGLELOG}"
          -o
          "${debian_changelog}"
        WORKING_DIRECTORY ${RICB_CPACK_TOOLS_DIR}
        ERROR_VARIABLE CREATE_DEBIAN_CHANGELOG_ERROR
      )
    else()
      if(EXISTS ${CPACK_DEBIAN_RESOURCE_FILE_CHANGELOG})
        configure_file(${CPACK_DEBIAN_RESOURCE_FILE_CHANGELOG} ${debian_changelog} COPYONLY)
      else()
        execute_process(
          COMMAND date -R
          OUTPUT_VARIABLE DATE_TIME
          OUTPUT_STRIP_TRAILING_WHITESPACE)
        file(WRITE ${debian_changelog}
          "${CPACK_DEBIAN_PACKAGE_NAME} (${DEBIAN_PACKAGE_VERSION}) ${DISTRI}; urgency=low\n\n"
          "  ${output_changelog_msg}\n\n"
          " -- ${CPACK_DEBIAN_PACKAGE_MAINTAINER}  ${DATE_TIME}\n"
          )
      endif()
    endif()

    ##########################################################################
    # Templates

    if (CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA)
      foreach(CF ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA})
        get_filename_component(CF_NAME ${CF} NAME)
        message("Writing debian/${CF_NAME}")
        configure_file(${CF} ${DEBIAN_SOURCE_DIR}/debian/${CF_NAME} @ONLY)
      endforeach()
    endif(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA)


    ##########################################################################
    # .orig.tar.gz
    #execute_process(COMMAND date +%y%m%d
    #  OUTPUT_VARIABLE day_suffix
    #  OUTPUT_STRIP_TRAILING_WHITESPACE
    #  )

    set(CPACK_SOURCE_IGNORE_FILES
       ${CPACK_SOURCE_IGNORE_FILES}
      "/build.*/"
      "/Testing/"
      "/test/"
      "/tmp/"
      "/ci/"
      "/packaging/"
      "/debian/"
      "/\\\\.git.*"
      "/\\\\.idea/"
      "/\\\\.codelite/"
      "*~$")

    set(package_file_name "${CPACK_DEBIAN_PACKAGE_NAME}_${DEBIAN_PACKAGE_VERSION}")

    file(WRITE "${CMAKE_BINARY_DIR}/Debian/${DISTRI}/cpack.cmake"
      "set(CPACK_GENERATOR TGZ)\n"
      "set(CPACK_PACKAGE_NAME \"${CPACK_DEBIAN_PACKAGE_NAME}\")\n"
      "set(CPACK_PACKAGE_VERSION \"${CPACK_PACKAGE_VERSION}\")\n"
      "set(CPACK_PACKAGE_FILE_NAME \"${package_file_name}.orig\")\n"
      "set(CPACK_PACKAGE_DESCRIPTION \"${CPACK_PACKAGE_NAME} Source\")\n"
      "set(CPACK_IGNORE_FILES \"${CPACK_SOURCE_IGNORE_FILES}\")\n"
      "set(CPACK_INSTALLED_DIRECTORIES \"${CPACK_SOURCE_INSTALLED_DIRECTORIES}\")\n"
      "set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)\n"
      )

    set(orig_file "${CMAKE_BINARY_DIR}/Debian/${DISTRI}/${package_file_name}.orig.tar.gz")

    add_custom_command(OUTPUT ${orig_file}
      COMMAND cpack --config ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/cpack.cmake
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Debian/${DISTRI}
      )

    add_custom_command(OUTPUT ${DEBIAN_SOURCE_DIR}/CMakeLists.txt
        COMMAND tar zxf ${orig_file}
        WORKING_DIRECTORY ${DEBIAN_SOURCE_DIR}
        DEPENDS ${orig_file}
        )

    ##############################################################################
    # debuild -S
    set(DEB_SOURCE_CHANGES
      ${CPACK_DEBIAN_PACKAGE_NAME}_${DEBIAN_PACKAGE_VERSION}_source.changes
      )

    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/${DEB_SOURCE_CHANGES}
      COMMAND ${DEBUILD_EXECUTABLE} --no-tgz-check -S
      WORKING_DIRECTORY ${DEBIAN_SOURCE_DIR}
      )
    add_custom_target(debuild_${DISTRI} ALL
                    DEPENDS ${DEBIAN_SOURCE_DIR}/CMakeLists.txt
                            ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/${DEB_SOURCE_CHANGES}
            )

    ##############################################################################
    # dput ppa:your-lp-id/ppa <source.changes>
    message(STATUS "Upload PPA is ${UPLOAD_PPA}")
    if(ARG_UPLOAD)
      if (ARG_DPUT_CONFIG_IN AND EXISTS ${ARG_DPUT_CONFIG_IN})
        set(DPUT_DIST ${DISTRI})
        configure_file(
            ${ARG_DPUT_CONFIG_IN}
            ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/dput.cf
            @ONLY
        )
        add_custom_target(dput_${DISTRI} ALL
            COMMAND ${DPUT_EXECUTABLE} -c ${CMAKE_BINARY_DIR}/Debian/${DISTRI}/dput.cf ${ARG_DPUT_HOST} ${DEB_SOURCE_CHANGES}
            DEPENDS debuild_${DISTRI}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Debian/${DISTRI}
        )
      else()
        add_custom_target(dput_${DISTRI} ALL
            COMMAND ${DPUT_EXECUTABLE} ${ARG_DPUT_HOST} ${DEB_SOURCE_CHANGES}
            DEPENDS debuild_${DISTRI}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Debian/${DISTRI}
        )
      endif()
    endif()
  endforeach(DISTRI)
endmacro()
