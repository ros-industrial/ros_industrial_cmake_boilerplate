=========================
CMake Boilerplate Scripts
=========================

|license apache 2.0|

.. |license apache 2.0| image:: https://img.shields.io/:license-Apache%202.0-yellowgreen.svg
   :target: https://opensource.org/licenses/Apache-2.0

|license bsd 3 clause|

.. |license bsd 3 clause| image:: https://img.shields.io/:license-BSD%203--Clause-orange.svg
   :target: https://opensource.org/licenses/BSD-3-Clause


This contains a collection of boilerplate CMake scripts and marcos.

Note: this package is *not* specific to ROS-Industrial and is usable with any package which uses CMake. The prefix was added to facilitate releasing this into different ROS distributions.

.. contents:: Table of Contents
   :depth: 3

Create Debian Package (Linux) or NuGet Package (Windows)
========================================================

The following process will generate a Debian or NuGet package leveraging cmake and cpack based on the OS.

The package should be located in the current directory.

``` bash
cd <workspace directory>
catkin build -DRICB_PACKAGE=ON
./src/ros_industrial_cmake_boilerplate/.run-cpack
```

Available Macros
================

Extract Package Metadata
-------------------------

This CMake macro will extract the package name and version from a package.xml file.
It will create two cmake variable **${PREFIX_ARG}_extracted_name** and **${PREFIX_ARG}_extracted_version**.

.. code-block:: cmake

   extract_package_metadata(${PREFIX_ARG})

Clang Tidy
----------

This CMake macro will add clang tidy to a provided target.

- `The clang-tidy documentation <https://clang.llvm.org/extra/clang-tidy/>`_
- `The list of clang-tidy checks <https://clang.llvm.org/extra/clang-tidy/checks/list.html>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easly be enable by external flag. If not provided it is automatically enabled.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} ARGUMENTS ${ARGN})

This configures clang-tidy with default arguments where any violation will produce compiler warnings.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_CLANG_TIDY_WARNING_ARGS})

This configures clang-tidy with default arguments where any violation will produce compiler errors.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_CLANG_TIDY_ERROR_ARGS})

This configures clang-tidy to use a .clang-tidy file if no arguments are provided

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME})

.. note::

   In some situation you may want to disable clang-tidy which is explained `here <https://clang.llvm.org/extra/clang-tidy/#id3>`_.

Include What You Use (IWYU)
---------------------------
This CMake macro will add IWYU to a given target

- `Why Include What You Use? <https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/WhyIWYU.md>`_
- `IWYU Documentation <https://github.com/include-what-you-use/include-what-you-use/blob/master/README.md>`_
- `Exclude headers from check <https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/IWYUPragmas.md>`_
- `Avoid Common Issues <https://www.incredibuild.com/blog/include-what-you-use-how-to-best-utilize-this-tool-and-avoid-common-issues/>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easly be enable by external flag. If not provided it is automatically enabled.

.. code-block:: cmake

   target_include_what_you_use(${PACKAGE_NAME} ARGUMENTS ${ARGN})

This CMake macro will add IWYU to a given target with default arguments.

.. code-block:: cmake

   target_include_what_you_use(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_IWYU_ARGS})


This CMake macro will add IWYU to all targets

.. code-block:: cmake

   include_what_you_use(ARGUMENTS ${ARGN})

This CMake macro will add IWYU to all targets with default arguments.

.. code-block:: cmake

   include_what_you_use(ARGUMENTS ${DEFAULT_IWYU_ARGS})


CppCheck
--------

This CMake macro will add CppCheck to a given target

- `CppCheck Wiki <https://sourceforge.net/p/cppcheck/wiki/Home/>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easly be enable by external flag. If not provided it is automatically enabled.

.. code-block:: cmake

   target_cppcheck(${PACKAGE_NAME} ARGUMENTS ${ARGN})


This CMake macro will add CppCheck to a given target with default arguments.

.. code-block:: cmake

   target_cppcheck(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_CPPCHECK_ARGS})


This CMake macro will add CppCheck to all targets

.. code-block:: cmake

   cppcheck(ARGUMENTS ${ARGN})


This CMake macro will add CppCheck to all targets with default arguments.

.. code-block:: cmake

   cppcheck(ARGUMENTS ${DEFAULT_CPPCHECK_ARGS})


Configure (Pure CMake Package)
------------------------------
This CMake macro simplifies the CMake package configure and install by performing multiple operations

* It installs the provided targets
* It exports the provided targets under the provided namespace
* It installs the package.xml file
* It creates and installs the ${PROJECT_NAME}-config.cmake and ${PROJECT_NAME}-config-version.cmake

.. code-block:: cmake

   configure_package(NAMESPACE <PACKAGE_NAMESPACE> TARGETS <TARGET_NAME_A> <TARGET_NAME_B>)

Sub macros used in configure package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The following macros are used by configure_package and can be used independently if needed

Install Targets
===============
This will install along with export them to ${PROJECT_NAME}-targets

.. code-block:: cmake

   install_targets(TARGETS targetA targetb)

Install package.xml
===================
This will install package.xml file

.. code-block:: cmake

   install_pkgxml()

Generate CMake Config Files
===========================
This will generate and install cmake config files

.. code-block:: cmake

   # Install export targets with provided namespace
   generate_package_config(EXPORT NAMSPACE namespace)

   #Install export targets with no namespace
   generate_package_config(EXPORT)

   # Install cmake config files and not install export targets
   generate_package_config() Install cmake config files and not install export targets

Install Ament Hooks
===================
Allows Colcon to find non-Ament packages when using workspace underlays

.. code-block:: cmake

   install_ament_hooks()

Set Target CXX VERSION
----------------------
This CMake macro simplifies setting the CXX version for the target

.. code-block:: cmake

   target_cxx_version(${PACKAGE_NAME} <INTERFACE|PRIVATE|PUBLIC> VERSION <CXX_VERSION>)

Example:
Set the version to 14 and PUBLIC.

.. code-block:: cmake

   target_cxx_version(${PACKAGE_NAME} PUBLIC VERSION 14)

Find GTest (Pure CMake Package)
---------------------------------------------
This CMake macro calls ``find_package(GTest REQUIRED)`` and checks for the ``GTest::GTest`` and ``GTest::Main`` targets. If the targets are missing it will create the targets using the CMake variables.

.. code-block:: cmake

   find_gtest()


Add Run Tests Target (Pure CMake Package)
-----------------------------------------
This CMake macro adds a custom target that will run the tests after they are finished building. You may pass an optional
argument true|false adding the ability do disable the running of tests as part of the build for CI which calls make test.

Add run test target (These will automatically run the test after build finishes)

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME>)

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME> true)

Add empty run test target

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME> false)


Add GTest Discover Tests (Pure CMake Package)
---------------------------------------------
This CMake macro call the appropriate gtest function to add a test based on the CMake version

.. code-block:: cmake

   add_gtest_discover_tests(<TARGET_NAME>)

Add Run Benchmark Target
------------------------
This CMake macro adds a custom target that will run the benchmarks after they are finished building.

Add run benchmark target (These will automatically run the benchmark after build finishes)

.. code-block:: cmake

   add_run_benchmark_target(<TARGET_NAME>)

.. code-block:: cmake

   add_run_benchmark_target(<TARGET_NAME> true)

Add empty run benchmark target

.. code-block:: cmake

   add_run_benchmark_target(<TARGET_NAME> false)


Code Coverage
-------------
These CMake macros add code coverage.

.. note:: Must call **initialize_code_coverage()** after project() in the CMakeLists.txt. This is required for all examples below.

From this point, there are two primary methods for adding instrumentation to targets:
1. A blanket instrumentation by calling `add_code_coverage()`, where all targets in that directory and all subdirectories are automatically instrumented.
2. Per-target instrumentation by calling `target_code_coverage(<TARGET_NAME>)`, where the target is given and thus only that target is instrumented. This applies to both libraries and executables.

To add coverage targets, such as calling `make ccov` to generate the actual coverage information for perusal or consumption, call `target_code_coverage(<TARGET_NAME>)` on an *executable* target.

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easly be enable by external flag. If not provided it is automatically enabled.

Examples
++++++++

Example 1: All targets instrumented

In this case, the coverage information reported will will be that of the `theLib` library target and `theExe` executable.

1a: Via global command

.. code-block:: cmake

   add_code_coverage() # Adds instrumentation to all targets
   add_library(theLib lib.cpp)
   add_executable(theExe main.cpp)
   target_link_libraries(theExe PRIVATE theLib)
   target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target (instrumentation already added via global anyways) for generating code coverage reports.

1b: Via target commands

.. code-block:: cmake

   add_library(theLib lib.cpp)
   target_code_coverage(theLib) # As a library target, adds coverage instrumentation but no targets.
   add_executable(theExe main.cpp)
   target_link_libraries(theExe PRIVATE theLib)
   target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target and instrumentation for generating code coverage reports.

Example 2: Target instrumented, but with regex pattern of files to be excluded from report

.. code-block:: cmake

   add_executable(theExe main.cpp non_covered.cpp)
   target_code_coverage(theExe EXCLUDE non_covered.cpp test/*) # As an executable target, the reports will exclude the non-covered.cpp file, and any files in a test/ folder.

Example 3: Target added to the 'ccov' and 'ccov-all' targets

.. code-block:: cmake

   add_code_coverage_all_targets(EXCLUDE test/*) # Adds the 'ccov-all' target set and sets it to exclude all files in test/ folders.
   add_executable(theExe main.cpp non_covered.cpp)
   target_code_coverage(theExe AUTO ALL EXCLUDE non_covered.cpp test/*) # As an executable target, adds to the 'ccov' and ccov-all' targets, and the reports will exclude the non-covered.cpp file, and any files in a test/ folder.
