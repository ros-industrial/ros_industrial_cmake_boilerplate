^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package ros_industrial_cmake_boilerplate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.4.0 (2023-02-20)
------------------

0.3.1 (2022-08-25)
------------------
* Fix code coverage macro to support plain visibility
* Contributors: Levi Armstrong

0.3.0 (2022-07-05)
------------------
* Fix target_code_coverage to support targets with plain visibility
* Update target_cxx_version to support windows
* Add missing include(GoogleTest) to find_gtest() macro
* Update package CI to use colcon
* Contributors: Levi Armstrong

0.2.16 (2022-06-22)
-------------------
* Always treat package description as a single string during extraction
* Fix cpack to generate correct names for nuget packages (`#64 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/64>`_)
* Added CPack macro from tesseract (`#62 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/62>`_)
* Contributors: Josh Langsfeld, Levi Armstrong, Michael Ripperger

0.2.15 (2022-01-30)
-------------------
* Add missing one value arg NAMESPACE to configure_package
* Auto generation of `*-config.cmake` files for simple cases (`#59 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/59>`_)
* Contributors: Josh Langsfeld, Levi Armstrong

0.2.14 (2021-12-03)
-------------------
* Add newer version of clang-tidy to the list
* Contributors: Levi Armstrong

0.2.13 (2021-11-10)
-------------------
* Add --output-on-failure to add_run_test_target
* Remove deprecated variables
* Add CXX_STANDARD_REQUIRED ON
* Contributors: Levi Armstrong, Levi-Armstrong

0.2.12 (2021-10-13)
-------------------
* Add colcon support
* Improve configure_package
* Contributors: Levi-Armstrong

0.2.11 (2021-07-02)
-------------------
* Rename clang-tidy keyword ERRORS_CHECKS to ERROR_CHECKS
* Contributors: Levi Armstrong

0.2.10 (2021-07-02)
-------------------
* Improve target_clang_tidy to support individual options over single argument list
* Break out individual function from configure_package
* Contributors: G.A. vd. Hoorn, Levi Armstrong

0.2.9 (2021-04-09)
------------------
* Add ENABLE functionality to initialize_code_coverage
* Improve cpack package naming
* Add cpack archive package
* Add CPACK to build debian and nuget package
* Extract description from package.xml
* Contributors: Levi Armstrong

0.2.8 (2021-02-08)
------------------
* Update package.xml to have buildtool_depend on cmake
* Set gtest discovery mode to PRE_TEST
* Moved include of GoogleTest into discover gtest macro
* Contributors: Levi Armstrong, Michael Ripperger

0.2.7 (2021-01-29)
------------------
* Add contributing file
* Add license files and update documentation
* Contributors: Levi Armstrong

0.2.6 (2021-01-26)
------------------
* Rename package to ros_industrial_cmake_boilerplate
* Contributors: Levi Armstrong

0.2.5 (2021-01-05)
------------------
* Bump version

0.2.4 (2021-01-05)
------------------
* Remove noetic.ignored which should go in the release repository

0.2.3 (2021-01-05)
------------------
* Add noetic.ignored to exclude gtest package during bloom release

0.2.1 (2021-01-05)
------------------
* Initial Release
* Contributors: Levi Armstrong, Michael Ripperger
