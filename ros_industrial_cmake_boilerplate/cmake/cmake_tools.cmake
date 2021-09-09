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

set(DEFAULT_CLANG_TIDY_WARNING_ARGS "-checks=${DEFAULT_CLANG_TIDY_CHECKS}")
message(DEPRECATED " CMake variable DEFAULT_CLANG_TIDY_WARNING_ARGS will be removed please use DEFAULT_CLANG_TIDY_CHECKS")
mark_as_advanced(DEFAULT_CLANG_TIDY_WARNING_ARGS)

set(DEFAULT_CLANG_TIDY_ERROR_ARGS "-checks=${DEFAULT_CLANG_TIDY_CHECKS}" "-warnings-as-errors=${DEFAULT_CLANG_TIDY_CHECKS}")
message(DEPRECATED " CMake variable DEFAULT_CLANG_TIDY_ERROR_ARGS will be removed please use DEFAULT_CLANG_TIDY_CHECKS")
mark_as_advanced(DEFAULT_CLANG_TIDY_ERROR_ARGS)

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
  # Allows Colcon to find non-Ament packages when using workspace underlays
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME} "")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/ament_index/resource_index/packages/${PROJECT_NAME} DESTINATION share/ament_index/resource_index/packages)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv "prepend-non-duplicate;AMENT_PREFIX_PATH;")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ament_prefix_path.dsv DESTINATION share/${PROJECT_NAME}/hook)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ros_package_path.dsv "prepend-non-duplicate;ROS_PACKAGE_PATH;")
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/share/${PROJECT_NAME}/hook/ros_package_path.dsv DESTINATION share/${PROJECT_NAME}/hook)
endmacro()

# Install the provided targets and export to ${PROJECT_NAME}-targets
# Usage: install_targets(TARGETS targetA targetb)
macro(install_targets)
  set(multiValueArgs TARGETS)
  cmake_parse_arguments(ARG "" "" "${multiValueArgs}" ${ARGN})
  install(TARGETS ${ARG_TARGETS}
          EXPORT ${PROJECT_NAME}-targets
          RUNTIME DESTINATION bin
          LIBRARY DESTINATION lib
          ARCHIVE DESTINATION lib)
endmacro()

# Install the package.xml used for catkin and ament
macro(install_pkgxml)
  install(FILES package.xml DESTINATION share/${PROJECT_NAME})
endmacro()

# Performs multiple operation so other packages may find a package
# Usage:
#   * generate_package_config(EXPORT NAMSPACE namespace) Install export targets with provided namespace
#   * generate_package_config(EXPORT) Install export targets with no namespace
#   * generate_package_config() Install cmake config files and not install export targets
#   * It exports the provided targets under the provided namespace if EXPORT option is set
#   * It create and install the ${PROJECT_NAME}-config.cmake and ${PROJECT_NAME}-config-version.cmake
macro(generate_package_config)
  set(options EXPORT)
  set(oneValueArgs NAMESPACE)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "" ${ARGN})

  if (ARG_EXPORT)
    if (ARG_NAMESPACE)
      install(EXPORT ${PROJECT_NAME}-targets NAMESPACE "${ARG_NAMESPACE}::" DESTINATION lib/cmake/${PROJECT_NAME})
    else()
      install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/cmake/${PROJECT_NAME})
    endif()
  endif()

  # Create cmake config files
  include(CMakePackageConfigHelpers)
  configure_package_config_file(${CMAKE_CURRENT_LIST_DIR}/cmake/${PROJECT_NAME}-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
    INSTALL_DESTINATION lib/cmake/${PROJECT_NAME}
    NO_CHECK_REQUIRED_COMPONENTS_MACRO)

  write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION} COMPATIBILITY ExactVersion)

  install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    DESTINATION lib/cmake/${PROJECT_NAME})

  if (ARG_EXPORT)
    if (ARG_NAMESPACE)
      export(EXPORT ${PROJECT_NAME}-targets NAMESPACE "${ARG_NAMESPACE}::" FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-targets.cmake)
    else()
      export(EXPORT ${PROJECT_NAME}-targets FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-targets.cmake)
    endif()
  endif()
endmacro()

# Performs multiple operation so other packages may find a package
# If Namespace is provided but no targets it is assumed targets were installed and must be exported
# Usage: configure_package(NAMSPACE namespace TARGETS targetA targetb)
#   * It installs the provided targets
#   * It exports the provided targets under the provided namespace
#   * It installs the package.xml file
#   * It create and install the ${PROJECT_NAME}-config.cmake and ${PROJECT_NAME}-config-version.cmake
macro(configure_package)
  set(oneValueArgs NAMESPACE)
  set(multiValueArgs TARGETS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # install package.xml
  install_pkgxml()

  # install and export targets if provided and generate package config
  if (ARG_TARGETS)
    install_targets(TARGETS ${ARG_TARGETS})
    generate_package_config(EXPORT NAMESPACE ${ARG_NAMESPACE})
  elseif(ARG_NAMESPACE)
    generate_package_config(EXPORT NAMESPACE ${ARG_NAMESPACE})
  else()
    generate_package_config()
  endif()

  install_ament_hooks()
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
        COMMAND ${CMAKE_CTEST_COMMAND} -V -O "/tmp/${PROJECT_NAME}_ctest.log" -C $<CONFIGURATION>)
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
      target_compile_options("${target}" INTERFACE -std=c++${ARG_VERSION})
    else()
      target_compile_features("${target}" INTERFACE cxx_std_${ARG_VERSION})
    endif()
  elseif(ARG_PUBLIC)
    if(CXX_FEATURE_FOUND EQUAL "-1")
      set_property(TARGET ${target} PROPERTY CXX_STANDARD ${ARG_VERSION})
      set_property(TARGET ${target} PROPERTY CXX_STANDARD_REQUIRED ON)
    else()
      target_compile_features("${target}" PUBLIC cxx_std_${ARG_VERSION})
    endif()
  elseif(ARG_PRIVATE)
    if(CXX_FEATURE_FOUND EQUAL "-1")
      set_property(TARGET ${target} PROPERTY CXX_STANDARD ${ARG_VERSION})
      set_property(TARGET ${target} PROPERTY CXX_STANDARD_REQUIRED ON)
    else()
      target_compile_features("${target}" PRIVATE cxx_std_${ARG_VERSION})
    endif()
  else()
    message(FATAL_ERROR "target_cxx_version: Must provide keyword INTERFACE | PRIVATE | PUBLIC")
  endif()
endmacro()

# Find relevant programs
find_program(CLANG_TIDY_EXE NAMES clang-tidy clang-tidy-10 clang-tidy-9 clang-tidy-8)
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
