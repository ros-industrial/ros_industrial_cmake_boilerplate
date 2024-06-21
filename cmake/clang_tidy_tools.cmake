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

# Find relevant programs
find_program(CLANG_TIDY_EXE NAMES clang-tidy-14 clang-tidy-13 clang-tidy-12 clang-tidy-11 clang-tidy-10 clang-tidy-9 clang-tidy-8 clang-tidy)
mark_as_advanced(FORCE CLANG_TIDY_EXE)
if(CLANG_TIDY_EXE)
  message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
else()
  message(STATUS "clang-tidy not found!")
  set(CMAKE_CXX_CLANG_TIDY "" CACHE STRING "" FORCE) # delete it
endif()

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

# Adds clang-tidy to all targets, with the given arguments being used as the options set.
macro(clang_tidy)
  set(oneValueArgs ENABLE)
  set(multiValueArgs ARGUMENTS)
  cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if((NOT DEFINED ARG_ENABLE) OR (ARG_ENABLE))
    if(CLANG_TIDY_EXE)
      if(ARG_ARGUMENTS)
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE};${ARG_ARGUMENTS}")
      else()
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
      endif()
    else()
      message(WARNING "Using clang_tidy but clang-tidy executable was not found!")
    endif()
  endif()
endmacro()

# Clears clang-tidy so it is not called on any following defined code
# compilation. clang-tidy can be re-enabled by another call to `clang_tidy()`.
macro(reset_clang_tidy)
  set(CMAKE_CXX_CLANG_TIDY "" CACHE STRING "" FORCE)
endmacro()
