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

set(DEFAULT_CPPCHECK_ARGS "--enable=warning,performance,portability,missingInclude;--template=\"[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)\";--suppress=missingIncludeSystem;--quiet;--verbose;--force;--inline-suppr")
mark_as_advanced(DEFAULT_CPPCHECK_ARGS)

# Find relevant programs
find_program(CPPCHECK_EXE NAMES "cppcheck")
mark_as_advanced(FORCE CPPCHECK_EXE)
if(CPPCHECK_EXE)
  message(STATUS "cppcheck found: ${CPPCHECK_EXE}")
else()
  message(STATUS "cppcheck not found!")
  set(CMAKE_CXX_CPPCHECK "" CACHE STRING "" FORCE) # delete it
endif()

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

# Clears cppcheck so it is not called on any following defined code compilation.
# It can be re-enabled by another call to `cppcheck()`.
macro(reset_cppcheck)
  set(CMAKE_CXX_CPPCHECK "" CACHE STRING "" FORCE)
endmacro()
