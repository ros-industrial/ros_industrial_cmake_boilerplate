# Copyright (C) 2018 by George Cave - gcave@stablecoder.ca
# Copyright (c) 2020, Southwest Research Institute
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# This checks if building on windows and if so enables exporting alls symbols.
# Note: To disable define CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS prior to find_packages(ros_industrial_cmake_boilerplate REQUIRED)
if(WIN32 AND NOT DEFINED CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS)
  message(VERBOSE "Enabling CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS!")
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

set(DEFAULT_CPPCHECK_ARGS "--enable=warning,performance,portability,missingInclude;--template=\"[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)\";--suppress=missingIncludeSystem;--quiet;--verbose;--force;--inline-suppr")
mark_as_advanced(DEFAULT_CPPCHECK_ARGS)

set(DEFAULT_IWYU_ARGS "-Xiwyu;any;-Xiwyu;iwyu;-Xiwyu;args")
mark_as_advanced(DEFAULT_IWYU_ARGS)

set(DEFAULT_CLANG_TIDY_CHECKS
  "-*, \
  bugprone-*, \
  cppcoreguidelines-avoid-goto, \
  cppcoreguidelines-c-copy-assignment-signature, \
  cppcoreguidelines-interfaces-global-init, \
  cppcoreguidelines-narrowing-conversions, \
  cppcoreguidelines-no-malloc, \
  cppcoreguidelines-slicing, \
  cppcoreguidelines-special-member-functions, \
  misc-*, \
  -misc-non-private-member-variables-in-classes, \
  modernize-*, \
  -modernize-use-trailing-return-type, \
  -modernize-use-nodiscard, \
  performance-*, \
  readability-avoid-const-params-in-decls, \
  readability-container-size-empty, \
  readability-delete-null-pointer, \
  readability-deleted-default, \
  readability-else-after-return, \
  readability-function-size, \
  readability-identifier-naming, \
  readability-inconsistent-declaration-parameter-name, \
  readability-misleading-indentation, \
  readability-misplaced-array-index, \
  readability-non-const-parameter, \
  readability-redundant-*, \
  readability-simplify-*, \
  readability-static-*, \
  readability-string-compare, \
  readability-uniqueptr-delete-release, \
  readability-rary-objects")
mark_as_advanced(DEFAULT_CLANG_TIDY_CHECKS)

# Adds clang-tidy checks to the target, with the given arguments being used
# as the options set.
macro(target_clang_tidy target)
  set(oneValueArgs ENABLE WARNINGS_AS_ERRORS HEADER_FILTER LINE_FILTER CHECKS CONFIG ERROR_CHECKS)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(CLANG_TIDY_EXE)
      get_target_property(${target}_type ${target} TYPE)
      if(NOT ${${target}_type} STREQUAL "INTERFACE_LIBRARY")
        set(CLANG_TIDY_ARGUMENTS_FULL "")

        if(ARG_HEADER_FILTER)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--header-filter=${ARG_HEADER_FILTER}")
        else()
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--header-filter=.*")
        endif()

        if(ARG_LINE_FILTER)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "-line-filter=${ARG_LINE_FILTER}")
        endif()

        if(ARG_CHECKS)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--checks=${ARG_CHECKS}")
        endif()

        if(ARG_ERROR_CHECKS)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--warnings-as-errors=${ARG_ERROR_CHECKS}")
        elseif((ARG_WARNINGS_AS_ERRORS) AND (ARG_CHECKS))
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--warnings-as-errors=${ARG_CHECKS}")
        endif()

        if(ARG_CONFIG)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "--config=${ARG_CONFIG}")
        endif()

        if(ARG_ARGUMENTS)
          list(APPEND CLANG_TIDY_ARGUMENTS_FULL "${ARG_ARGUMENTS}")
        endif()

        if(ARG_ARGUMENTS)
          set_target_properties("${target}" PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_EXE};${ARG_ARGUMENTS}")
        else()
          set_target_properties("${target}" PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
        endif()
      endif()
    else()
      message(WARNING "Using target_clang_tidy but clang tidy executable was not found!")
    endif()
  endif()
endmacro()

# Adds include_what_you_use to the target, with the given arguments being
# used as the options set.
macro(target_include_what_you_use target)
  set(oneValueArgs ENABLE)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(IWYU_EXE)
      if(ARG_ARGUMENTS)
        set_target_properties("${target}" PROPERTIES CXX_INCLUDE_WHAT_YOU_USE "${IWYU_EXE};${ARG_ARGUMENTS}")
      else()
        set_target_properties("${target}" PROPERTIES CXX_INCLUDE_WHAT_YOU_USE "${IWYU_EXE};${DEFAULT_IWYU_ARGS}")
      endif()
    else()
      message(WARNING "Using target_include_what_you_use but iwyu executable was not found!")
    endif()
  endif()
endmacro()

# Adds include_what_you_use to all targets, with the given arguments being used as the options set.
macro(include_what_you_use)
  set(oneValueArgs ENABLE)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(IWYU_EXE)
      if(ARG_ARGUMENTS)
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_EXE};${ARG_ARGUMENTS}")
      else()
        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_EXE};${DEFAULT_IWYU_ARGS}")
      endif()
    else()
      message(WARNING "Using include_what_you_use but iwyu executable was not found!")
    endif()
  endif()
endmacro()

# Adds cppcheck to the target, with the given arguments being used as the options set.
macro(target_cppcheck target)
  set(oneValueArgs ENABLE)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(CPPCHECK_EXE)
      if(ARG_ARGUMENTS)
        set_target_properties("${target}" PROPERTIES CXX_CPPCHECK "${CPPCHECK_EXE};${ARG_ARGUMENTS}")
      else()
        set_target_properties("${target}" PROPERTIES CXX_CPPCHECK "${CPPCHECK_EXE};${DEFAULT_CPPCHECK_ARGS}")
      endif()
    else()
      message(WARNING "Using target_cppcheck but cppcheck executable was not found!")
    endif()
  endif()
endmacro()

# Adds cppcheck to all targets, with the given arguments being used as the options set.
macro(cppcheck)
  set(oneValueArgs ENABLE)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(CPPCHECK_EXE)
      if(ARG_ARGUMENTS)
        set(CMAKE_CXX_CPPCHECK "${CPPCHECK_EXE};${ARG_ARGUMENTS}")
      else()
        set(CMAKE_CXX_CPPCHECK "${CPPCHECK_EXE};${DEFAULT_CPPCHECK_ARGS}")
      endif()
    else()
      message(WARNING "Using cppcheck but cppcheck executable was not found!")
    endif()
  endif()
endmacro()

# Allows Colcon to find non-Ament packages when using workspace underlays
macro(install_ament_hooks)
  set(oneValueArgs COMPONENT)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})

  if (NOT ARG_COMPONENT)
    set(ARG_COMPONENT ${PROJECT_NAME})
  endif()

  # Allows Colcon to find non-Ament packages when using workspace underlays
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME} "")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME} DESTINATION share/ament_index/resource_index/packages COMPONENT ${ARG_COMPONENT})
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv "prepend-non-duplicate;AMENT_PREFIX_PATH;")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv DESTINATION share/${PROJECT_NAME}/hook COMPONENT ${ARG_COMPONENT})
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ros_package_path.dsv "prepend-non-duplicate;ROS_PACKAGE_PATH;")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ros_package_path.dsv DESTINATION share/${PROJECT_NAME}/hook COMPONENT ${ARG_COMPONENT})
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv "prepend-non-duplicate;PYTHONPATH;lib/python3/dist-packages")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/python_path.dsv DESTINATION share/${PROJECT_NAME}/hook COMPONENT ${ARG_COMPONENT})
endmacro()

# Install the provided targets and export to ${ARG_COMPONENT}-target, but this export name can be overrided by providing
# the export name with usage below.
# Usage: install_targets(TARGETS targetA targetb)
# Usage: install_targets(COMPONENT example TARGETS targetA targetb)
macro(install_targets)
  set(oneValueArgs COMPONENT)
  set(multiValueArgs TARGETS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ARG_COMPONENT)
    set(ARG_COMPONENT ${PROJECT_NAME})
  endif()

  install(TARGETS ${ARG_TARGETS}
          EXPORT ${ARG_COMPONENT}-targets
          COMPONENT ${ARG_COMPONENT}
          RUNTIME DESTINATION bin
          LIBRARY DESTINATION lib
          ARCHIVE DESTINATION lib)
endmacro()

# Install the package.xml used for catkin and ament
macro(install_pkgxml)
  set(oneValueArgs COMPONENT)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})

  if (NOT ARG_COMPONENT)
    set(ARG_COMPONENT ${PROJECT_NAME})
  endif()

  install(FILES package.xml DESTINATION share/${PROJECT_NAME} COMPONENT ${ARG_COMPONENT})
endmacro()

# Create a default *-config.cmake.in with simple dependency finding
function(make_default_package_config)
    set(oneValueArgs CONFIG_NAME CONFIG_FILE COMPONENT HAS_TARGETS )
    set(multiValueArgs DEPENDENCIES CFG_EXTRAS SUPPORTED_COMPONENTS)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ARG_COMPONENT)
      set(ARG_COMPONENT ${PROJECT_NAME})
    endif()

    if (NOT ARG_CONFIG_NAME)
      set(ARG_CONFIG_NAME ${ARG_COMPONENT})
    endif()

    if (ARG_CONFIG_NAME STREQUAL PROJECT_NAME)
      string(CONCAT ricb_pkgconfig
          "# Default *-config.cmake file created by ros-industrial-cmake-boilerplate\n\n"
          "@PACKAGE_INIT@\n\n"
          "set(@PROJECT_NAME@_FOUND ON)\n"
      )
    else()
      string(CONCAT ricb_pkgconfig
          "# Default *-config.cmake file created by ros-industrial-cmake-boilerplate\n\n"
          "set(@PROJECT_NAME@_${ARG_COMPONENT}_FOUND ON)\n"
      )
    endif()

    if (ARG_DEPENDENCIES)
        set(find_dep_cmds "include(CMakeFindDependencyMacro)")
        foreach(dep IN LISTS ARG_DEPENDENCIES)
            list(APPEND find_dep_cmds "find_dependency(${dep})")
        endforeach()

        # Convert list to newline-separated string
        string(REPLACE ";" "\n" ricb_dependencies "${find_dep_cmds}")
        string(APPEND ricb_pkgconfig "\n# Dependencies\n" "${ricb_dependencies}\n")
    endif()

    if (ARG_SUPPORTED_COMPONENTS)
      string(REPLACE ";" " " supported_components_string "${ARG_SUPPORTED_COMPONENTS}")
      string(APPEND ricb_pkgconfig "\n# Components\n"
        "set(@PROJECT_NAME@_SUPPORTED_COMPONENTS ${supported_components_string})\n"
        "if (NOT @PROJECT_NAME@_FIND_COMPONENTS)\n"
        "  foreach(component \${@PROJECT_NAME@_SUPPORTED_COMPONENTS})\n"
        "    include(\${CMAKE_CURRENT_LIST_DIR}/\${component}-config.cmake)\n"
        "  endforeach()\n"
        "else()\n"
        "  foreach(component \${@PROJECT_NAME@_FIND_COMPONENTS})\n"
        "    if(NOT component IN_LIST @PROJECT_NAME@_SUPPORTED_COMPONENTS)\n"
        "      set(@PROJECT_NAME@_\${component}_FOUND OFF)\n"
        "      set(@PROJECT_NAME@_\${component}_NOT_FOUND_MESSAGE \"Unsupported component\")\n"
        "      if (@PROJECT_NAME@_FIND_REQUIRED_\${component})\n"
        "        message(FATAL_ERROR \"Project \${PROJECT_NAME}, failed to find required component \${component} for package @PROJECT_NAME@. Supported components are: \${@PROJECT_NAME@_SUPPORTED_COMPONENTS}\")\n"
        "      endif()\n"
        "    else()\n"
        "      include(\${CMAKE_CURRENT_LIST_DIR}/\${component}-config.cmake)\n"
        "    endif()\n"
        "  endforeach()\n"
        "endif()\n\n"
      )
    endif()

    if (ARG_CFG_EXTRAS)
        string(APPEND ricb_pkgconfig "\n# Extra configuration files\n")
        foreach(extra_config IN LISTS ARG_CFG_EXTRAS)
          get_filename_component(CFG_EXTRA_FILENAME ${extra_config} NAME BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
          string(APPEND ricb_pkgconfig "include(\"\${CMAKE_CURRENT_LIST_DIR}/${CFG_EXTRA_FILENAME}\")\n")
        endforeach()
    endif()

    if (ARG_HAS_TARGETS)
        string(APPEND ricb_pkgconfig "\n# Targets\n"
             "include(\"\${CMAKE_CURRENT_LIST_DIR}/${ARG_COMPONENT}-targets.cmake\")\n")
    endif()

    file(WRITE ${ARG_CONFIG_FILE} ${ricb_pkgconfig})
endfunction()

# Performs multiple operation so other packages may find a package and package components
# The default export name is ${PROJECT_NAME} but it can be overriden by providing EXPORT_NAME
# Options:
#    * EXPORT - indicate if trargets should be exported
# One Value Args:
#    * COMPONENT (Optional)   - the name given to the export ${ARG_COMPONENT}-targets, if not provided PROJECT_NAME is used
#    * CONFIG_NAME (Optional) - the name given to the export ${ARG_COMPONENT}-config.cmake, if not provided COMPONENT is used
#    * NAMESPACE (Optional)   - the namespace assigned for exported targets
# Multi Value Args:
#    * DEPENDENCIES (Optional)         - list of dependencies to be loaded in the package config
#    * CFG_EXTRAS (Optional)           - list of extra cmake config files to be loaded in package config
#    * SUPPORTED_COMPONENTS (Optional) - list of supported components
# Usage:
#   * generate_package_config(EXPORT NAMSPACE namespace) Install export targets with provided namespace
#   * generate_package_config(EXPORT) Install export targets with no namespace
#   * generate_package_config() Install cmake config files and not install export targets
#   * It exports the provided targets under the provided namespace ${ARG_COMPONENT}-targets, if EXPORT option is set
#   * It creates and install the ${ARG_CONFIG_NAME}-config.cmake
#   * In not component, it create and installs ${ARG_CONFIG_NAME}-config-version.cmake
function(generate_package_config)
  set(options EXPORT)
  set(oneValueArgs CONFIG_NAME COMPONENT NAMESPACE)
  set(multiValueArgs DEPENDENCIES CFG_EXTRAS SUPPORTED_COMPONENTS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ARG_COMPONENT)
    set(ARG_COMPONENT ${PROJECT_NAME})
  endif()

  if (NOT ARG_CONFIG_NAME)
    set(ARG_CONFIG_NAME ${ARG_COMPONENT})
  endif()

  if (ARG_EXPORT)
    if (ARG_NAMESPACE)
      install(EXPORT ${ARG_COMPONENT}-targets NAMESPACE "${ARG_NAMESPACE}::" DESTINATION lib/cmake/${PROJECT_NAME} COMPONENT ${ARG_COMPONENT})
    else()
      install(EXPORT ${ARG_COMPONENT}-targets DESTINATION lib/cmake/${PROJECT_NAME} COMPONENT ${ARG_COMPONENT})
    endif()
  endif()

  set(config_template "${CMAKE_CURRENT_LIST_DIR}/cmake/${ARG_CONFIG_NAME}-config.cmake.in")
  if (NOT EXISTS ${config_template})
    message(STATUS "No package config template file found, creating default one")
    set(config_template "${CMAKE_BINARY_DIR}/${ARG_CONFIG_NAME}-config.cmake.in")

    make_default_package_config(
      CONFIG_NAME ${ARG_CONFIG_NAME}
      CONFIG_FILE ${config_template}
      COMPONENT ${ARG_COMPONENT}
      SUPPORTED_COMPONENTS ${ARG_SUPPORTED_COMPONENTS}
      HAS_TARGETS ${ARG_EXPORT}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})

    foreach(extra_config IN LISTS ARG_CFG_EXTRAS)
      install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${extra_config} DESTINATION lib/cmake/${PROJECT_NAME}/ COMPONENT ${ARG_COMPONENT})
    endforeach()

  else ()
    message(STATUS "Found package config template: ${config_template}")
    if (ARG_DEPENDENCIES)
        message(WARNING
            "Package configuration: DEPENDENCIES provided, but template file '${config_template}'"
            " exists and will be used instead")
    endif()
    if (ARG_CFG_EXTRAS)
        message(WARNING
            "Package configuration: CFG_EXTRAS provided, but template file '${config_template}'"
            " exists and will be used instead")
    endif()
  endif()

  # Create cmake config files
  include(CMakePackageConfigHelpers)
  configure_package_config_file(${config_template}
    ${CMAKE_BINARY_DIR}/${ARG_CONFIG_NAME}-config.cmake
    INSTALL_DESTINATION lib/cmake/${PROJECT_NAME}
    NO_CHECK_REQUIRED_COMPONENTS_MACRO)

  install(FILES
    "${CMAKE_BINARY_DIR}/${ARG_CONFIG_NAME}-config.cmake"
    DESTINATION lib/cmake/${PROJECT_NAME}
    COMPONENT ${ARG_COMPONENT})

  if (ARG_CONFIG_NAME STREQUAL PROJECT_NAME)
    write_basic_package_version_file(${CMAKE_BINARY_DIR}/${ARG_CONFIG_NAME}-config-version.cmake
      VERSION ${PROJECT_VERSION} COMPATIBILITY ExactVersion)

    install(FILES
      "${CMAKE_BINARY_DIR}/${ARG_CONFIG_NAME}-config-version.cmake"
      DESTINATION lib/cmake/${PROJECT_NAME}
      COMPONENT ${ARG_COMPONENT})
  endif()

  if (ARG_EXPORT)
    if (ARG_NAMESPACE)
      export(EXPORT ${ARG_COMPONENT}-targets NAMESPACE "${ARG_NAMESPACE}::" FILE ${CMAKE_BINARY_DIR}/${ARG_COMPONENT}-targets.cmake)
    else()
      export(EXPORT ${ARG_COMPONENT}-targets FILE ${CMAKE_BINARY_DIR}/${ARG_COMPONENT}-targets.cmake)
    endif()
  endif()
endfunction()

# Performs multiple operation so other packages may find a package
# If Namespace is provided but no targets it is assumed targets were installed and must be exported
# One Value Args:
#   * NAMESPACE - This will prepend <namespace>:: to the target names as they are written to the import file
#   * COMPONENT - The component to associate with package related files like package.xml, *-config.cmake, etc.. If not provided the PROJECT_NAME is used.
# Multi Value Args:
#   * TARGETS                - The targets from the project to be installed
#   * SUPPORTED_COMPONENTS   - The packages supported find_package components if any
#   * DEPENDENCIES           - The dependencies to be written to the packages Config.cmake file
#   * CFG_EXTRAS             - The extra cmake files to be include in the packages Config.cmake file
# Usage: configure_package(NAMSPACE namespace TARGETS targetA targetb COMPONENTS componentA componentB DEPENDENCIES Eigen3 "Boost COMPONENTS system filesystem" CFG_EXTRAS target-extras.cmake)
#   * It installs the provided targets
#   * It exports the provided targets under the provided namespace
#   * It installs the package.xml file
#   * It create and install the ${PROJECT_NAME}-config.cmake and ${PROJECT_NAME}-config-version.cmake
macro(configure_package)
  set(oneValueArgs NAMESPACE COMPONENT)
  set(multiValueArgs TARGETS DEPENDENCIES CFG_EXTRAS SUPPORTED_COMPONENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ARG_COMPONENT)
    set(ARG_COMPONENT ${PROJECT_NAME})
  endif()

  # install package.xml
  install_pkgxml(COMPONENT ${ARG_COMPONENT})

  # install and export targets if provided and generate package config
  if (ARG_TARGETS)
    install_targets(COMPONENT ${ARG_COMPONENT} TARGETS ${ARG_TARGETS})
    generate_package_config(EXPORT
      CONFIG_NAME ${PROJECT_NAME}
      COMPONENT ${ARG_COMPONENT}
      SUPPORTED_COMPONENTS ${ARG_SUPPORTED_COMPONENTS}
      NAMESPACE ${ARG_NAMESPACE}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  elseif(ARG_NAMESPACE)
    generate_package_config(EXPORT
      CONFIG_NAME ${PROJECT_NAME}
      COMPONENT ${ARG_COMPONENT}
      SUPPORTED_COMPONENTS ${ARG_SUPPORTED_COMPONENTS}
      NAMESPACE ${ARG_NAMESPACE}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  else()
    generate_package_config(
      CONFIG_NAME ${PROJECT_NAME}
      COMPONENT ${ARG_COMPONENT}
      SUPPORTED_COMPONENTS ${ARG_SUPPORTED_COMPONENTS}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  endif()

  install_ament_hooks(COMPONENT ${ARG_COMPONENT})
endmacro()

# Performs multiple operation so other packages may find a package's component
# If Namespace is provided but no targets it is assumed targets were installed and must be exported
# One Value Args:
#   * NAMESPACE - This will prepend <namespace>:: to the target names as they are written to the import file
#   * COMPONENT - The component name
# Multi Value Args:
#   * TARGETS      - The targets from the project to be installed
#   * DEPENDENCIES - The dependencies to be written to the packages Config.cmake file
#   * CFG_EXTRAS   - The extra cmake files to be include in the packages Config.cmake file
# Usage: configure_package(COMPONENT kdl NAMSPACE namespace TARGETS targetA targetb DEPENDENCIES Eigen3 "Boost COMPONENTS system filesystem" CFG_EXTRAS target-extras.cmake)
#   * It installs the provided targets
#   * It exports the provided targets under the provided namespace
macro(configure_component)
  set(oneValueArgs COMPONENT NAMESPACE)
  set(multiValueArgs TARGETS DEPENDENCIES CFG_EXTRAS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ARG_COMPONENT)
    message(FATAL_ERROR "configure_component is missing COMPONENT entry")
  endif()

  # install and export targets if provided and generate package config
  if (ARG_TARGETS)
    install_targets(COMPONENT ${ARG_COMPONENT} TARGETS ${ARG_TARGETS})
    generate_package_config(EXPORT
      COMPONENT ${ARG_COMPONENT}
      NAMESPACE ${ARG_NAMESPACE}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  elseif(ARG_NAMESPACE)
    generate_package_config(EXPORT
      COMPONENT ${ARG_COMPONENT}
      NAMESPACE ${ARG_NAMESPACE}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  else()
    generate_package_config(
      COMPONENT ${ARG_COMPONENT}
      DEPENDENCIES ${ARG_DEPENDENCIES}
      CFG_EXTRAS ${ARG_CFG_EXTRAS})
  endif()

endmacro()

# This macro call find_package(GTest REQUIRED) and check for targets GTest::GTest and GTest::Main and if missign it will create them
# Usage: find_gtest()
macro(find_gtest)
  find_package(GTest REQUIRED)
  if(NOT TARGET GTest::GTest)
    add_library(GTest::GTest INTERFACE IMPORTED)
    set_target_properties(GTest::GTest PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")
    if (${GTEST_LIBRARIES})
      set_target_properties(GTest::GTest PROPERTIES INTERFACE_LINK_LIBRARIES "${GTEST_LIBRARIES}")
    else()
      if (MSVC)
        set_target_properties(GTest::GTest PROPERTIES INTERFACE_LINK_LIBRARIES "gtest.lib")
      else()
        set_target_properties(GTest::GTest PROPERTIES INTERFACE_LINK_LIBRARIES "libgtest.so")
      endif()
    endif()
  endif()

  if(NOT TARGET GTest::Main)
    add_library(GTest::Main INTERFACE IMPORTED)
    set_target_properties(GTest::Main PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")
    if (${GTEST_MAIN_LIBRARIES})
      set_target_properties(GTest::Main PROPERTIES INTERFACE_LINK_LIBRARIES "${GTEST_MAIN_LIBRARIES}")
    else()
      if (MSVC)
        set_target_properties(GTest::Main PROPERTIES INTERFACE_LINK_LIBRARIES "gtest_main.lib")
      else()
        set_target_properties(GTest::Main PROPERTIES INTERFACE_LINK_LIBRARIES "libgtest_main.so")
      endif()
    endif()
  endif()
  include(GoogleTest)
endmacro()

# This macro call the appropriate gtest function to add a test based on the cmake version
# Usage: add_gtest_discover_tests(target)
macro(add_gtest_discover_tests target)
  if(${CMAKE_VERSION} VERSION_LESS "3.10.0")
    gtest_add_tests(${target} "" AUTO)
  else()
    include(GoogleTest)
    gtest_discover_tests(${target} DISCOVERY_MODE PRE_TEST)
  endif()
endmacro()

# This macro add a custom target that will run the tests after they are finished building when
# This is added to allow ability do disable the running of tests as part of the build for CI which calls make test
#    * add_run_tests_target() adds run test target
#    * add_run_tests_target(ENABLE ON/TRUE) adds run test target
#    * add_run_tests_target(ENABLE OFF/FALSE) adds empty run test target
macro(add_run_tests_target)
  set(oneValueArgs ENABLE)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    add_custom_target(run_tests ALL
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure -V -O "/tmp/${PROJECT_NAME}_ctest.log" -C $<CONFIGURATION>)
  else()
    add_custom_target(run_tests)
  endif()
endmacro()

# This macro add a custom target that will run the benchmarks after they are finished building.
# Usage: add_run_benchmark_target(benchmark_name)
# Results are saved to /test/benchmarks/${benchmark_name}_results.json in the build directory
#    * add_run_benchmark_target(benchmark_name) adds run benchmark target
#    * add_run_benchmark_target(benchmark_name ENABLE ON/TRUE) adds run benchmark target
#    * add_run_benchmark_target(benchmark_name ENABLE OFF/FALSE) adds empty run benchmark target
macro(add_run_benchmark_target benchmark_name)
  set(oneValueArgs ENABLE)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    add_custom_target(run_benchmark_${benchmark_name} ALL
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ./test/benchmarks/${benchmark_name} --benchmark_out_format=json --benchmark_out="./test/benchmarks/${benchmark_name}_results.json")
  else()
    add_custom_target(run_benchmark_${benchmark_name})
  endif()
  add_dependencies(run_benchmark_${benchmark_name} ${benchmark_name})
endmacro()

# These macros facilitate setting cxx version for a target
macro(target_cxx_version target)
  set(options INTERFACE PUBLIC PRIVATE)
  set(oneValueArgs VERSION)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "" ${ARGN})
  list(FIND CMAKE_CXX_COMPILE_FEATURES cxx_std_${ARG_VERSION} CXX_FEATURE_FOUND)
  if (ARG_INTERFACE)
    if(CXX_FEATURE_FOUND EQUAL "-1")
      if(WIN32)
        target_compile_options("${target}" INTERFACE "/std:c++${ARG_VERSION}")
      else()
        target_compile_options("${target}" INTERFACE -std=c++${ARG_VERSION})
      endif()
    else()
      target_compile_features("${target}" INTERFACE cxx_std_${ARG_VERSION})
    endif()
  elseif(ARG_PUBLIC)
    if(CXX_FEATURE_FOUND EQUAL "-1")
      set_property(TARGET ${target} PROPERTY CXX_STANDARD ${ARG_VERSION})
      set_property(TARGET ${target} PROPERTY CXX_STANDARD_REQUIRED ON)
      if(WIN32 AND MSVC_VERSION GREATER_EQUAL "1900" AND CMAKE_VERSION LESS 3.10)
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag("/std:c++${ARG_VERSION}" _cpp_latest_flag_supported)
        if(_cpp_latest_flag_supported)
          target_compile_options("${target}" PUBLIC "/std:c++${ARG_VERSION}")
        endif()
      endif()
    else()
      target_compile_features("${target}" PUBLIC cxx_std_${ARG_VERSION})
    endif()
  elseif(ARG_PRIVATE)
    if(CXX_FEATURE_FOUND EQUAL "-1")
      set_property(TARGET ${target} PROPERTY CXX_STANDARD ${ARG_VERSION})
      set_property(TARGET ${target} PROPERTY CXX_STANDARD_REQUIRED ON)
      if(WIN32 AND MSVC_VERSION GREATER_EQUAL "1900" AND CMAKE_VERSION LESS 3.10)
        include(CheckCXXCompilerFlag)
        check_cxx_compiler_flag("/std:c++${ARG_VERSION}" _cpp_latest_flag_supported)
        if(_cpp_latest_flag_supported)
          target_compile_options("${target}" PUBLIC "/std:c++${ARG_VERSION}")
        endif()
      endif()
    else()
      target_compile_features("${target}" PRIVATE cxx_std_${ARG_VERSION})
    endif()
  else()
    message(FATAL_ERROR "target_cxx_version: Must provide keyword INTERFACE | PRIVATE | PUBLIC")
  endif()
endmacro()

# Find relevant programs
find_program(CLANG_TIDY_EXE NAMES clang-tidy-14 clang-tidy-13 clang-tidy-12 clang-tidy-11 clang-tidy-10 clang-tidy-9 clang-tidy-8 clang-tidy)
mark_as_advanced(FORCE CLANG_TIDY_EXE)
if(CLANG_TIDY_EXE)
  message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
else()
  message(STATUS "clang-tidy not found!")
  set(CMAKE_CXX_CLANG_TIDY "" CACHE STRING "" FORCE) # delete it
endif()

find_program(IWYU_EXE NAMES "include-what-you-use")
mark_as_advanced(FORCE IWYU_EXE)
if(IWYU_EXE)
  message(STATUS "include-what-you-use found: ${IWYU_EXE}")
else()
  message(STATUS "include-what-you-use not found!")
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "" CACHE STRING "" FORCE) # delete it
endif()

find_program(CPPCHECK_EXE NAMES "cppcheck")
mark_as_advanced(FORCE CPPCHECK_EXE)
if(CPPCHECK_EXE)
  message(STATUS "cppcheck found: ${CPPCHECK_EXE}")
else()
  message(STATUS "cppcheck not found!")
  set(CMAKE_CXX_CPPCHECK "" CACHE STRING "" FORCE) # delete it
endif()
