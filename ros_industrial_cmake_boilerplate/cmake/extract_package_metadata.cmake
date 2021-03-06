# Copyright (c) 2020, ABB Schweiz AG
# All rights reserved.
#
# Redistribution and use in source and binary forms, with
# or without modification, are permitted provided that
# the following conditions are met:
#
#   * Redistributions of source code must retain the
#     above copyright notice, this list of conditions
#     and the following disclaimer.
#   * Redistributions in binary form must reproduce the
#     above copyright notice, this list of conditions
#     and the following disclaimer in the documentation
#     and/or other materials provided with the
#     distribution.
#   * Neither the name of ABB nor the names of its
#     contributors may be used to endorse or promote
#     products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

macro(extract_package_metadata prefix)
  # Read the package manifest.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/package.xml" package_xml_str)

  # Extract project name.
  if(NOT package_xml_str MATCHES "<name>([A-Za-z0-9_]+)</name>")
    message(FATAL_ERROR "Could not parse project name from package manifest (aborting)")
  else()
    set(${prefix}_extracted_name ${CMAKE_MATCH_1})
  endif()

  # Extract project version.
  if(NOT package_xml_str MATCHES "<version>([0-9]+.[0-9]+.[0-9]+)</version>")
    message(FATAL_ERROR "Could not parse project version from package manifest (aborting)")
  else()
    set(${prefix}_extracted_version ${CMAKE_MATCH_1})
  endif()

  # Extract project description.
  if(NOT package_xml_str MATCHES "<description>(.*)</description>")
    message(FATAL_ERROR "Could not parse project description from package manifest (aborting)")
  else()
    string(REGEX REPLACE " +" " " CMAKE_MATCH_1 "${CMAKE_MATCH_1}")
    string(REGEX REPLACE "\"" "'" CMAKE_MATCH_1 "${CMAKE_MATCH_1}")
    string(REGEX REPLACE "\n" "" CMAKE_MATCH_1 "${CMAKE_MATCH_1}")
    string(STRIP ${CMAKE_MATCH_1} CMAKE_MATCH_1)
    set(${prefix}_extracted_description ${CMAKE_MATCH_1})
  endif()
endmacro()
