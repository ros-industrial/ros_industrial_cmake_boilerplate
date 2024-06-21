#########################
CMake Boilerplate Scripts
#########################

|license apache 2.0|

.. |license apache 2.0| image:: https://img.shields.io/:license-Apache%202.0-yellowgreen.svg
   :target: https://opensource.org/licenses/Apache-2.0

|license bsd 3 clause|

.. |license bsd 3 clause| image:: https://img.shields.io/:license-BSD%203--Clause-orange.svg
   :target: https://opensource.org/licenses/BSD-3-Clause


This contains a collection of boilerplate CMake scripts and marcos.

Note: this package is *not* specific to ROS-Industrial and is usable with any package which uses CMake. The prefix was added to facilitate releasing this into different ROS distributions.

.. contents:: Table of Contents
   :depth: 4

********************************************************
Create Debian Package (Linux) or NuGet Package (Windows)
********************************************************

The following process will generate a Debian or NuGet package leveraging CMake and CPack based on the OS.

The package should be located in the current directory.

``` bash
cd <workspace directory>
catkin build -DRICB_PACKAGE=ON
./src/ros_industrial_cmake_boilerplate/.run-cpack
```

****************
Available Macros
****************

Extract Package Metadata
========================

This CMake macro will extract the package name and version from a package.xml file.
It will create two cmake variable **${PREFIX_ARG}_extracted_name** and **${PREFIX_ARG}_extracted_version**.

.. code-block:: cmake

   extract_package_metadata(${PREFIX_ARG})

Clang Tidy
==========

This CMake macro will add clang-tidy to all targets

.. code-block:: cmake

   clang_tidy(ARGUMENTS ${ARGN})
   # or
   clang_tidy(ARGUMENTS ${ARGN} ENABLE ${USER_ENABLE_ARG})

This CMake macro will add clang-tidy to all targets with default arguments.

.. code-block:: cmake

   clang_tidy(ARGUMENTS ${DEFAULT_CLANG_TIDY_CHECKS})
   # or
   clang_tidy(ARGUMENTS ${DEFAULT_CLANG_TIDY_CHECKS} ENABLE ${USER_ENABLE_ARG})

Clears clang-tidy so it is not called on any following defined code compilation. It can be re-enabled by another call to `clang_tidy()`.

.. code-block:: cmake

   reset_clang_tidy()

This CMake macro will add clang-tidy to a provided target.

- `The clang-tidy documentation <https://clang.llvm.org/extra/clang-tidy/>`_
- `The list of clang-tidy checks <https://clang.llvm.org/extra/clang-tidy/checks/list.html>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easily be enabled by an external flag. If not provided it is automatically enabled.

Single Argument Keywords:

================== ======== ===========
Keyword             Type    Description
================== ======== ===========
ENABLE              ON/OFF  Enable/Disable clang-tidy
WARNINGS_AS_ERRORS  ON/OFF  Treat warnings as errors. If ERROR_CHECKS is not provided, it will use CHECKS to treat as errors.
HEADER_FILTER       String  Default to '.*' if not provided. Regular expression matching the names of the headers to output diagnostics from.
LINE_FILTER         String  List of files with line ranges to filter the warnings.
CHECKS              String  Comma-separated list of globs with optional '-' prefix. Globs are processed in order of appearance in the list. Globs without the '-' prefix add checks with matching names to the set, globs with the '-' prefix remove checks with matching names from the set of enabled checks. This option's value is appended to the value of the 'Checks' option in the .clang-tidy file, if any.
CONFIG              String  YAML/JSON format. If not provided, clang-tidy will attempt to find a file named .clang-tidy for each source file in its parent directories.
ERROR_CHECKS        String  Upgrades warnings to errors. Same format as 'CHECKS'. This option's value is appended to the value of the 'WarningsAsErrors' option in the .clang-tidy file, if any.
================== ======== ===========

Multip Value Argument Keywords:

================== ======== ===========
Keyword             Type    Description
================== ======== ===========
ARGUMENTS           String  This supports adding additional arguments to be passed to the clang-tidy. You could just use this if desired over the single keywords except for the ENABLE to pass all arguments to clang-tidy if desired.
================== ======== ===========

This configures clang-tidy with default arguments where any violation will produce compiler warnings.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} CHECKS ${DEFAULT_CLANG_TIDY_CHECKS})

This configures clang-tidy with default arguments where any violation will produce compiler errors.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} CHECKS ${DEFAULT_CLANG_TIDY_CHECKS} WARNINGS_AS_ERRORS ON)

This configures clang-tidy with custom error checks which can be different from the warning checks where any violation will produce compiler errors.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} CHECKS ${DEFAULT_CLANG_TIDY_CHECKS} ERROR_CHECKS ${DEFAULT_CLANG_TIDY_CHECKS})

This configures clang-tidy with a header filter. If not provided it will default to ".*".

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} HEADER_FILTER ".*")

This configures clang-tidy with line filter as a JSON array of objects.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} LINE_FILTER "[{"name":"file1.cpp","lines":[[1,3],[5,7]]},{"name":"file2.h"}]")

This configures clang-tidy with config in YAML/JSON format.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} CONFIG ""{Checks: '*', CheckOptions: [{key: x, value: y}]}")

This configures clang-tidy to use a .clang-tidy file if no arguments are provided

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME})

This configures clang-tidy with arguments list.

.. code-block:: cmake

   target_clang_tidy(${PACKAGE_NAME} ARGUMENTS ${ARGN})

.. note::

   In some situations, you may want to disable clang-tidy which is explained `here <https://clang.llvm.org/extra/clang-tidy/#id3>`_.

Include What You Use (IWYU)
===========================
This CMake macro will add IWYU to a given target

- `Why Include What You Use? <https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/WhyIWYU.md>`_
- `IWYU Documentation <https://github.com/include-what-you-use/include-what-you-use/blob/master/README.md>`_
- `Exclude headers from check <https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/IWYUPragmas.md>`_
- `Avoid Common Issues <https://www.incredibuild.com/blog/include-what-you-use-how-to-best-utilize-this-tool-and-avoid-common-issues/>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easily be enabled by an external flag. If not provided it is automatically enabled.

.. code-block:: cmake

   target_include_what_you_use(${PACKAGE_NAME} ARGUMENTS ${ARGN})

This CMake macro will add IWYU to a given target with default arguments.

.. code-block:: cmake

   target_include_what_you_use(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_IWYU_ARGS})


This CMake macro will add IWYU to all targets

.. code-block:: cmake

   include_what_you_use(ARGUMENTS ${ARGN})
   # or
   include_what_you_use(ARGUMENTS ${ARGN} ENABLE ${USER_ENABLE_ARG})

This CMake macro will add IWYU to all targets with default arguments.

.. code-block:: cmake

   include_what_you_use(ARGUMENTS ${DEFAULT_IWYU_ARGS})
   # or
   include_what_you_use(ARGUMENTS ${DEFAULT_IWYU_ARGS} ENABLE ${USER_ENABLE_ARG})

Clears IWYU so it is not called on any following defined code compilation. It can be re-enabled by another call to `include_what_you_use()`.

.. code-block:: cmake

   reset_include_what_you_use()

CppCheck
========

This CMake macro will add CppCheck to a given target

- `CppCheck Wiki <https://sourceforge.net/p/cppcheck/wiki/Home/>`_

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easily be enabled by the external flag. If not provided it is automatically enabled.

.. code-block:: cmake

   target_cppcheck(${PACKAGE_NAME} ARGUMENTS ${ARGN})


This CMake macro will add CppCheck to a given target with default arguments.

.. code-block:: cmake

   target_cppcheck(${PACKAGE_NAME} ARGUMENTS ${DEFAULT_CPPCHECK_ARGS})


This CMake macro will add CppCheck to all targets

.. code-block:: cmake

   cppcheck(ARGUMENTS ${ARGN})
   # or
   cppcheck(ARGUMENTS ${ARGN} ENABLE ${USER_ENABLE_ARG})

This CMake macro will add CppCheck to all targets with default arguments.

.. code-block:: cmake

   cppcheck(ARGUMENTS ${DEFAULT_CPPCHECK_ARGS})
   # or
   cppcheck(ARGUMENTS ${DEFAULT_CPPCHECK_ARGS} ENABLE ${USER_ENABLE_ARG})

Clears CppCheck so it is not called on any following defined code compilation. It can be re-enabled by another call to `cppcheck()`.

.. code-block:: cmake

   reset_cppcheck()

Sanitizer Tools
===============

Sanitizers are tools that perform checks during a program’s runtime and returns issues, and as such, along with unit testing, code coverage and static analysis, is another tool to add to the programmers toolbox. And of course, like the previous tools, are tragically simple to add into any project using CMake, allowing any project and developer to quickly and easily use.

A quick rundown of the tools available, and what they do:

* `LeakSanitizer <https://clang.llvm.org/docs/LeakSanitizer.html>`_ detects memory leaks, or issues where memory is allocated and never deallocated, causing programs to slowly consume more and more memory, eventually leading to a crash.
* `AddressSanitizer <https://clang.llvm.org/docs/AddressSanitizer.html>`_ is a fast memory error detector. It is useful for detecting most issues dealing with memory, such as:
   * Out of bounds accesses to heap, stack, global
   * Use after free
   * Use after return
   * Use after scope
   * Double-free, invalid free
   * Memory leaks (using LeakSanitizer)
* `ThreadSanitizer <https://clang.llvm.org/docs/ThreadSanitizer.html>`_ detects data races for multi-threaded code.
* `UndefinedBehaviourSanitizer <https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>`_ detects the use of various features of C/C++ that are explicitly listed as resulting in undefined behaviour. Most notably: 
   * Using misaligned or null pointer.
   * Signed integer overflow
   * Conversion to, from, or between floating-point types which would overflow the destination
   * Division by zero
   * Unreachable code
* `MemorySanitizer <https://clang.llvm.org/docs/MemorySanitizer.html>`_ detects uninitialized reads.
* `Control Flow Integrity <https://clang.llvm.org/docs/ControlFlowIntegrity.html>`_ is designed to detect certain forms of undefined behaviour that can potentially allow attackers to subvert the program's control flow.

These are used by declaring the `USE_SANITIZER` CMake variable as string containing any of:
* Address
* Memory
* MemoryWithOrigins
* Undefined
* Thread
* Leak
* CFI

Multiple values are allowed, e.g. `-DUSE_SANITIZER=Address,Leak` but some sanitizers cannot be combined together, e.g.`-DUSE_SANITIZER=Address,Memory` will result in configuration error. The delimeter character is not required and `-DUSE_SANITIZER=AddressLeak` would work as well.

CPack
=====

Configure Package Without Components
------------------------------------
Configure package for cpack which does not leverage components

* One Value Args:
   * VERSION          - The package version
   * MAINTAINER_NAME  - The package maintainer name
   * MAINTAINER_EMAIL - The package maintainer email
   * VENDOR           - The package vender
   * DESCRIPTION      - The package description
   * LICENSE_FILE     - The package license file
   * README_FILE      - The package readme
   * PACKAGE_PREFIX   - The package prefix applied to all cpack generated files
* Multi Value Args:
   * LINUX_BUILD_DEPENDS   - The linux build dependencies required via apt install (If not provided LINUX_DEPENDS is used)
   * WINDOWS_BUILD_DEPENDS - The windows build dependencies required via nuget install (If not provided WINDOWS_DEPENDS is used)
   * LINUX_DEPENDS         - The linux dependencies required via apt install
   * WINDOWS_DEPENDS       - The windows dependencies required via nuget install

.. code-block:: cmake

   cpack(
     VERSION ${pkg_extracted_version}
     MAINTAINER <https://github.com/ros-industrial-consortium/tesseract>
     DESCRIPTION ${pkg_extracted_description}
     LICENSE_FILE ${CMAKE_CURRENT_LIST_DIR}/../LICENSE
     README_FILE ${CMAKE_CURRENT_LIST_DIR}/../README.md
     LINUX_DEPENDS
       "libboost-system-dev"
       "libboost-filesystem-dev"
       "libboost-serialization-dev"
       "libconsole-bridge-dev"
       "libtinyxml2-dev"
       "libeigen3-dev"
       "libyaml-cpp-dev"
     WINDOWS_DEPENDS
       "boost_system"
       "boost_filesystem;"
       "boost_serialization"
       "console-bridge"
       "tinyxml2"
       "Eigen3"
       "yaml-cpp")

Configure Package With Components
---------------------------------
This requires two macros one used in the components cmake file another for the top most package cmake file.

Configure Component
^^^^^^^^^^^^^^^^^^^
Configure components for cpack

* One Value Args:
   * COMPONENT      - The component name
   * VERSION        - The package version
   * DESCRIPTION    - The package description
   * PACKAGE_PREFIX - The package prefix applied to all cpack generated files
* Multi Value Args:
   * LINUX_BUILD_DEPENDS   - The linux build dependencies required via apt install (If not provided LINUX_DEPENDS is used)
   * WINDOWS_BUILD_DEPENDS - The windows build dependencies required via nuget install (If not provided WINDOWS_DEPENDS is used)
   * LINUX_DEPENDS         - The linux dependencies required via apt install
   * WINDOWS_DEPENDS       - The windows dependencies required via nuget install
   * COMPONENT_DEPENDS     - The component dependencies required from this package

.. code-block:: cmake

   cpack_component(
     COMPONENT IKFAST # must be uppercase
     VERSION ${pkg_extracted_version}
     DESCRIPTION "Tesseract Kinematics ikfast implementation"
     COMPONENT_DEPENDS core)

Configure Components Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Configure package leveraging components for cpack

* One Value Args:
   * VERSION          - The package version
   * MAINTAINER_NAME  - The package maintainer name
   * MAINTAINER_EMAIL - The package maintainer email
   * VENDOR           - The package vender
   * DESCRIPTION      - The package description
   * LICENSE_FILE     - The package license file
   * README_FILE      - The package readme
   * PACKAGE_PREFIX   - The package prefix applied to all cpack generated files
* Multi Value Args:
   * COMPONENT_DEPENDS - The component dependencies required from this package

.. code-block:: cmake

   cpack_component_package(
     VERSION ${pkg_extracted_version}
     MAINTAINER <https://github.com/ros-industrial-consortium/tesseract>
     DESCRIPTION ${pkg_extracted_description}
     LICENSE_FILE ${CMAKE_CURRENT_LIST_DIR}/../LICENSE
     README_FILE ${CMAKE_CURRENT_LIST_DIR}/../README.md)


Configure Debian Source Package
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Create debian source package leveraging cpack for upload to ppa like launchpad.net

* One Value Args:
   * CHANGLELOG (Required)         - The file path to the package CHANGELOG.rst
   * PACKAGE_PREFIX (Optional)     - The package prefix applied to all cpack generated files
   * UPLOAD (Optional)             - Indicate if it should be uploaded to ppa
   * DEBIAN_INCREMENT              - The debian increment to be used, default is zero
   * DPUT_HOST (Optional/Required) - The ppa to upload to. Only required if UPLOAD is enabled
   * DPUT_CONFIG_IN (Optional)     - The dput config.in file. If not provide one is created.
* Multi Value Args:
   * DISTRIBUTIONS - The linux distrabution to deploy
* Leveraged CPack Variable: When using the cpack macros above these are automatically set
   * CPACK_PACKAGE_DESCRIPTION (Required)
   * CPACK_PACKAGE_VERSION (Required)
   * CPACK_PACKAGE_DESCRIPTION_FILE (Optional)
   * CPACK_SOURCE_IGNORE_FILES (Optional)
   * CPACK_DEBIAN_PACKAGE_NAME (Required)
   * CPACK_DEBIAN_PACKAGE_SECTION (Required)
   * CPACK_DEBIAN_PACKAGE_PRIORITY (Required)
   * CPACK_DEBIAN_PACKAGE_MAINTAINER (Required)
   * CPACK_DEBIAN_PACKAGE_MAINTAINER_NAME (Required)
   * CPACK_DEBIAN_PACKAGE_MAINTAINER_EMAIL (Required)
   * CPACK_DEBIAN_PACKAGE_ARCHITECTURE (Required)
   * CPACK_DEBIAN_PACKAGE_DESCRIPTION (Optional)
   * CPACK_DEBIAN_PACKAGE_BUILD_DEPENDS (Optional)
   * CPACK_DEBIAN_PACKAGE_DEPENDS (Optional)
   * CPACK_DEBIAN_PACKAGE_HOMEPAGE (Optional)
   * CPACK_COMPONENT_<COMPONENT>_DEPENDS (Reqired if components exist and enabled)
   * CPACK_DEBIAN_<COMPONENT>_PACKAGE_ARCHITECTURE (Reqired if components exist and enabled)
   * CPACK_DEBIAN_<COMPONENT>_DESCRIPTION (Reqired if components exist and enabled)
   * CPACK_DEBIAN_<COMPONENT>_PACKAGE_ARCHITECTURE (Reqired if components exist and enabled)
   * CPACK_DEBIAN_<COMPONENT>_PACKAGE_DEPENDS (Reqired if components exist and enabled)
   * CPACK_DEBIAN_<COMPONENT>_PACKAGE_BUILD_DEPENDS (Reqired if components exist and enabled)


.. code-block:: cmake

   cpack_debian_source_package(
     CHANGLELOG ${CMAKE_CURRENT_LIST_DIR}/CHANGELOG.rst
     UPLOAD ${RICB_PACKAGE_SOURCE_UPLOAD}
     DPUT_HOST ${RICB_PACKAGE_SOURCE_DPUT_HOST}
     DEBIAN_INCREMENT ${RICB_PACKAGE_SOURCE_DEBIAN_INCREMENT}
     DISTRIBUTIONS ${RICB_PACKAGE_SOURCE_DISTRIBUTIONS}
   )


Configure (Pure CMake Package)
==============================
This CMake macro simplifies the CMake package configure and install by performing multiple operations

Configure Package
-----------------
Performs multiple operation so other packages may find a package

If Namespace is provided but no targets it is assumed targets were installed and must be exported

* One Value Args:
   * NAMESPACE - This will prepend <namespace>:: to the target names as they are written to the import file
* Multi Value Args:
   * TARGETS      - The targets from the project to be installed
   * COMPONENTS   - The packages supported find_package components if any
   * DEPENDENCIES - The dependencies to be written to the packages Config.cmake file
   * CFG_EXTRAS   - The extra cmake files to be include in the packages Config.cmake file
* Usage:
   * It installs the provided targets
   * It exports the provided targets under the provided namespace
   * It installs the package.xml file
   * It creates and installs the ${PROJECT_NAME}-config.cmake and ${PROJECT_NAME}-config-version.cmake

.. code-block:: cmake

   configure_package(
     NAMESPACE <PACKAGE_NAMESPACE>
     TARGETS <TARGET_NAME_A> <TARGET_NAME_B>
     COMPONENTS <COMPONENT_NAME_A> <COMPONENT_NAME_B>
     DEPENDENCIES <deps>...
     CFG_EXTRAS <cmake files>...
   )

Example:

.. code-block:: cmake

   configure_package(
     NAMESPACE
       tesseract
     TARGETS
       ${PROJECT_NAME}
     DEPENDENCIES
       Eigen3
       TinyXML2
       yaml-cpp
       "Boost COMPONENTS system filesystem serialization"
     CFG_EXTRAS
       cmake/tesseract_common-extras.cmake
   )

To create the config cmake file, the macro by default looks for a configuration template
``cmake/${PROJECT_NAME}-config.cmake.in`` provided by the package. If not present, a default one
will be generated. If generated automatically, package dependencies will be included from the
arguments listed by ``DEPENDENCIES``. Additional configuration CMake scripts can also be included
with relative paths listed in the ``CFG_EXTRAS`` argument. The scripts should be installed alongside
the generated package config file, in ``lib/cmake/${PROJECT_NAME}``.


Configure Component
-------------------
Performs multiple operation so other packages may find a package's component

If Namespace is provided but no targets it is assumed targets were installed and must be exported

* One Value Args:
   * NAMESPACE - This will prepend <namespace>:: to the target names as they are written to the import file
   * COMPONENT - The component name
* Multi Value Args:
   * TARGETS      - The targets from the project to be installed
   * DEPENDENCIES - The dependencies to be written to the packages Config.cmake file
   * CFG_EXTRAS   - The extra cmake files to be include in the packages Config.cmake file
* Usage:
   * It installs the provided targets
   * It exports the provided targets under the provided namespace

.. code-block:: cmake

   configure_component(
     COMPONENT <COMPONENT_NAME>
     NAMESPACE <PACKAGE_NAMESPACE>
     TARGETS <TARGET_NAME_A> <TARGET_NAME_B>
     DEPENDENCIES <deps>...
     CFG_EXTRAS <cmake files>...
   )

Example:

.. code-block:: cmake

   configure_component(
     COMPONENT
       kdl
     NAMESPACE
       tesseract
     TARGETS
       ${PROJECT_NAME}_kdl ${PROJECT_NAME}_kdl_factories
     DEPENDENCIES
       Eigen3
       TinyXML2
       yaml-cpp
       "Boost COMPONENTS system filesystem serialization"
     CFG_EXTRAS
       cmake/tesseract_common-extras.cmake
   )

To create the config cmake file, the macro by default looks for a configuration template
``cmake/<COMPONENT_NAME>-config.cmake.in`` provided by the package. If not present, a default one
will be generated. If generated automatically, package dependencies will be included from the
arguments listed by ``DEPENDENCIES``. Additional configuration CMake scripts can also be included
with relative paths listed in the ``CFG_EXTRAS`` argument. The scripts should be installed alongside
the generated package config file, in ``lib/cmake/${PROJECT_NAME}``.


Sub macros used in configure the package
----------------------------------------
The following macros are used by configure_package and can be used independently if needed

Install Targets
^^^^^^^^^^^^^^^
This will install targets along associated with the provided component and export them to ${ARG_COMPONENT}-targets

* One Value Args:
   * COMPONENT (Optional) - The component name to associate the targets with, if not provided ${PROJECT_NAME} is used
* Multi Value Args:
   * TARGETS - The targets from the project to be installed


.. code-block:: cmake

   install_targets(TARGETS targetA targetb)

Install package.xml
^^^^^^^^^^^^^^^^^^^
This will install the package.xml file

.. code-block:: cmake

   install_pkgxml()

Generate CMake Config Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Performs multiple operation so other packages may find a package and package components
The default export name is ${PROJECT_NAME} but it can be overriden by providing EXPORT_NAME

* Options:
   * EXPORT    - indicate if trargets should be exported
* One Value Args:
   * COMPONENT (Optional)   - the name given to the export ${ARG_COMPONENT}-targets, if not provided PROJECT_NAME is used
   * CONFIG_NAME (Optional) - the name given to the export ${ARG_COMPONENT}-config.cmake, if not provided COMPONENT is used
   * NAMESPACE (Optional)   - the namespace assigned for exported targets
* Multi Value Args:
   * DEPENDENCIES (Optional)         - list of dependencies to be loaded in the package config
   * CFG_EXTRAS (Optional)           - list of extra cmake config files to be loaded in package config
   * SUPPORTED_COMPONENTS (Optional) - list of supported components
* Usage:
   * generate_package_config(EXPORT NAMSPACE namespace) Install export targets with provided namespace
   * generate_package_config(EXPORT) Install export targets with no namespace
   * generate_package_config() Install cmake config files and not install export targets
   * It exports the provided targets under the provided namespace ${ARG_COMPONENT}-targets, if EXPORT option is set
   * It creates and install the ${ARG_CONFIG_NAME}-config.cmake
   * In not component, it create and installs ${ARG_CONFIG_NAME}-config-version.cmake


.. code-block:: cmake

   # Install and export targets with provided namespace
   generate_package_config(EXPORT NAMSPACE namespace)

   #Install and export targets with no namespace
   generate_package_config(EXPORT)

   # Install CMake config files and not install export targets
   generate_package_config() Install CMake config files and not install export targets

   # Install and export targets for package with components
   generate_package_config(EXPORT CONFIG_NAME ${PROJECT_NAME} SUPPORTED_COMPONENTS componentA componentB)

   # Install and export targets for component
   generate_package_config(EXPORT
     COMPONENT kdl
     NAMESPACE namespace
     DEPENDENCIES packageA packageB
     CFG_EXTRAS extraA.cmake extraB.cmake)

Additionally, ``DEPENDENCIES``, ``CFG_EXTRAS`` and ``SUPPORTED_COMPONENTS`` are passed for generated CMake config files.

Install Ament Hooks
^^^^^^^^^^^^^^^^^^^
Allows Colcon to find non-Ament packages when using workspace underlays

.. code-block:: cmake

   install_ament_hooks()

Set Target CXX VERSION
======================
This CMake macro simplifies setting the CXX version for the target

.. code-block:: cmake

   target_cxx_version(${PACKAGE_NAME} <INTERFACE|PRIVATE|PUBLIC> VERSION <CXX_VERSION>)

Example:
Set the version to 14 and PUBLIC.

.. code-block:: cmake

   target_cxx_version(${PACKAGE_NAME} PUBLIC VERSION 14)

Find GTest (Pure CMake Package)
===============================
This CMake macro calls ``find_package(GTest REQUIRED)`` and checks for the ``GTest::GTest`` and ``GTest::Main`` targets. If the targets are missing it will create the targets using the CMake variables.

.. code-block:: cmake

   find_gtest()


Add Run Tests Target (Pure CMake Package)
=========================================
This CMake macro adds a custom target that will run the tests after they are finished building. You may pass an optional
argument true|false adding the ability to disable the running of tests as part of the build for CI which calls make test.

Add run test target (These will automatically run the test after build finishes)

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME>)

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME> true)

Add empty run test target

.. code-block:: cmake

   add_run_tests_target(<TARGET_NAME> false)


Add GTest Discover Tests (Pure CMake Package)
=============================================
This CMake macro call the appropriate GTest function to add a test based on the CMake version

.. code-block:: cmake

   add_gtest_discover_tests(<TARGET_NAME>)

Add Run Benchmark Target
========================
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
=============
These CMake macros add code coverage.

.. note:: Must call **initialize_code_coverage()** after project() in the CMakeLists.txt. This is required for all examples below.

From this point, there are two primary methods for adding instrumentation to targets:
1. A blanket instrumentation by calling `add_code_coverage()`, where all targets in that directory and all subdirectories are automatically instrumented.
2. Per-target instrumentation by calling `target_code_coverage(<TARGET_NAME>)`, where the target is given and thus only that target is instrumented. This applies to both libraries and executables.

To add coverage targets, such as calling `make ccov` to generate the actual coverage information for perusal or consumption, call `target_code_coverage(<TARGET_NAME>)` on an *executable* target.

.. note:: Each of the macros can take an ENABLE ON/OFF so they can easily be enabled by an external flag. If not provided it is automatically enabled.

Exclude Code From Code Coverage
-------------------------------

================== ===========
Keyword             Description
================== ===========
LCOV_EXCL_LINE     Lines containing this marker will be excluded.
LCOV_EXCL_START    Marks the beginning of an excluded section. The current line is part of this section.
LCOV_EXCL_STOP     Marks the end of an excluded section. The current line not part of this section.
================== ===========

.. note:: You can replace LCOV above with GCOV or GCOVR.

Example 1: All targets instrumented
-----------------------------------

In this case, the coverage information reported will be that of the `theLib` library target and `theExe` executable.

1a: Via global command
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: cmake

   add_code_coverage() # Adds instrumentation to all targets
   add_library(theLib lib.cpp)
   add_executable(theExe main.cpp)
   target_link_libraries(theExe PRIVATE theLib)
   target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target (instrumentation already added via global anyways) for generating code coverage reports.

1b: Via target commands
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: cmake

   add_library(theLib lib.cpp)
   target_code_coverage(theLib) # As a library target, adds coverage instrumentation but no targets.
   add_executable(theExe main.cpp)
   target_link_libraries(theExe PRIVATE theLib)
   target_code_coverage(theExe) # As an executable target, adds the 'ccov-theExe' target and instrumentation for generating code coverage reports.

Example 2: Target instrumented, but with regex pattern of files to be excluded from the report
----------------------------------------------------------------------------------------------

.. code-block:: cmake

   add_executable(theExe main.cpp non_covered.cpp)
   target_code_coverage(theExe EXCLUDE non_covered.cpp test/*) # As an executable target, the reports will exclude the non-covered.cpp file, and any files in a test/ folder.

Example 3: Target added to the 'ccov' and 'ccov-all' targets
------------------------------------------------------------

.. code-block:: cmake

   add_code_coverage_all_targets(EXCLUDE test/*) # Adds the 'ccov-all' target set and sets it to exclude all files in test/ folders.
   add_executable(theExe main.cpp non_covered.cpp)
   target_code_coverage(theExe AUTO ALL EXCLUDE non_covered.cpp test/*) # As an executable target, adds to the 'ccov' and ccov-all' targets, and the reports will exclude the non-covered.cpp file, and any files in a test/ folder.

Example 4: ROS add_rostest_gtest usage
------------------------------------------------------------

.. code-block:: cmake

   add_rostest_gtest(test_node test/test_node.test test/test_node.cpp)
   target_include_directories(test_node SYSTEM PUBLIC {catkin_INCLUDE_DIRS})
   target_link_libraries(test_node ${catkin_LIBRARIES})
   target_code_coverage(
     test_node
     ALL
     RUN_COMMAND rostest test_node test_node.test
     EXCLUDE ${COVERAGE_EXCLUDE}
     ENABLE ${ENABLE_CODE_COVERAGE})
