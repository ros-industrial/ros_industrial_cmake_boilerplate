find_package(GTest QUIET)
if ( NOT GTest_FOUND )

  include(ExternalProject)

  if (NOT UPDATE_DISCONNECTED)
    set(UPDATE_DISCONNECTED ON)
  endif()

  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(GTEST_CXX_FLAGS "-w -std=c++14")
    set(GTEST_C_FLAGS "-w")

    ExternalProject_Add(GTest
      GIT_REPOSITORY        https://github.com/google/googletest.git
      GIT_TAG               release-1.8.1
      SOURCE_DIR            ${CMAKE_BINARY_DIR}/../googletest-src
      BINARY_DIR            ${CMAKE_BINARY_DIR}/../googletest-build
      UPDATE_DISCONNECTED   ${UPDATE_DISCONNECTED}
      CMAKE_CACHE_ARGS
              -DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}
              -DCMAKE_BUILD_TYPE:STRING=Release
              -DCMAKE_CXX_FLAGS:STRING=${GTEST_CXX_FLAGS}
              -DCMAKE_C_FLAGS:STRING=${GTEST_C_FLAGS}
              -DBUILD_GMOCK:BOOL=OFF
              -DBUILD_GTEST:BOOL=ON
              -DBUILD_SHARED_LIBS:BOOL=ON
    )
    file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/include)
    set(GTEST_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/include)
    set(GTEST_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/lib/libgtest.so)
    set(GTEST_MAIN_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/lib/libgtest_main.so)

  elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    ExternalProject_Add(GTest
      GIT_REPOSITORY        https://github.com/google/googletest.git
      GIT_TAG               release-1.8.1
      SOURCE_DIR            ${CMAKE_BINARY_DIR}/../googletest-src
      BINARY_DIR            ${CMAKE_BINARY_DIR}/../googletest-build
      UPDATE_DISCONNECTED   ${UPDATE_DISCONNECTED}
      CMAKE_CACHE_ARGS
              -DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}
              -DCMAKE_BUILD_TYPE:STRING=Release
              -DBUILD_GMOCK:BOOL=OFF
              -DBUILD_GTEST:BOOL=ON
              -DBUILD_SHARED_LIBS:BOOL=ON
    )
    file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/include)
    set(GTEST_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/include)
    set(GTEST_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/bin/libgtest.dll)
    set(GTEST_MAIN_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}/bin/libgtest_main.dll)
  endif()
endif()

if(NOT TARGET GTest::GTest)
  find_package(Threads QUIET)

  add_library(GTest::GTest INTERFACE IMPORTED)
  set_target_properties(GTest::GTest PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")
  if(TARGET Threads::Threads)
      set_target_properties(GTest::GTest PROPERTIES INTERFACE_LINK_LIBRARIES "${GTEST_LIBRARIES};Threads::Threads")
  else()
    set_target_properties(GTest::GTest PROPERTIES INTERFACE_LINK_LIBRARIES "${GTEST_LIBRARIES}")
  endif()
endif()

if(NOT TARGET GTest::Main)
  add_library(GTest::Main INTERFACE IMPORTED)
  set_target_properties(GTest::Main PROPERTIES INTERFACE_LINK_LIBRARIES "${GTEST_MAIN_LIBRARIES};GTest::GTest")
endif()
