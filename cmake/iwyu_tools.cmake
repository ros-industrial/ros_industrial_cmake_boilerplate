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

set(DEFAULT_IWYU_ARGS "-Xiwyu;any;-Xiwyu;iwyu;-Xiwyu;args")
mark_as_advanced(DEFAULT_IWYU_ARGS)

# Find relevant programs
find_program(IWYU_EXE NAMES "include-what-you-use")
mark_as_advanced(FORCE IWYU_EXE)
if(IWYU_EXE)
  message(STATUS "include-what-you-use found: ${IWYU_EXE}")
else()
  message(STATUS "include-what-you-use not found!")
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "" CACHE STRING "" FORCE) # delete it
endif()

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

# Clears include-what-you-use so it is not called on any following defined code
# compilation. It can be re-enabled by another call to `include_what_you_use()`.
macro(reset_include_what_you_use)
  set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "" CACHE STRING "" FORCE)
endmacro()
