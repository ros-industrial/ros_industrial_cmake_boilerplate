^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package ros_industrial_cmake_boilerplate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Forthcoming
-----------
* Make _supported_components capitalized in package config with components
* Make supported_components unique in package config to avoid conflict
* Contributors: Levi Armstrong

0.5.2 (2023-09-02)
------------------
* Add CPack Build Depends for creating debian source package
* Contributors: Levi Armstrong

0.5.1 (2023-09-02)
------------------
* Add check for component Unspecified and generate error if using cpack with components (`#85 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/85>`_)
* Contributors: Levi Armstrong

0.5.0 (2023-09-01)
------------------
* Add cpack create debian source package with upload support (`#84 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/84>`_)
* Add cpack metapackge
* Add cpack component support
* Add find_package component support (`#82 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/82>`_)
* Update readme to include how to exclude code from code coverage
* Contributors: Levi Armstrong

0.4.8 (2023-07-17)
------------------
* Add code coverage executable RUN_COMMAND mulit-arg to support rostest (`#80 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/80>`_)
* Contributors: Levi Armstrong

0.4.7 (2023-06-27)
------------------
* Add python hook to install_ament_hooks
* Contributors: Levi Armstrong

0.4.6 (2023-03-06)
------------------
* Fix artifacts directory in github actions (`#77 <https://github.com/marip8/cmake_common_scripts/issues/77>`_)
* Contributors: Chris Schindlbeck

0.4.5 (2023-02-28)
------------------
* Make deps installation non-interactive (`#76 <https://github.com/marip8/cmake_common_scripts/issues/76>`_)
* Contributors: Michael Ripperger

0.4.4 (2023-02-28)
------------------
* Removed sudo from CI commands (`#75 <https://github.com/marip8/cmake_common_scripts/issues/75>`_)
* Contributors: Michael Ripperger

0.4.3 (2023-02-28)
------------------
* Fixed CI yaml file (`#74 <https://github.com/marip8/cmake_common_scripts/issues/74>`_)
* Contributors: Michael Ripperger

0.4.2 (2023-02-28)
------------------
* Minor Updates (`#73 <https://github.com/marip8/cmake_common_scripts/issues/73>`_)
  * Updated relative locations of license and README files
  * Updated debian build job to run on Ubuntu 20.04
* Contributors: Michael Ripperger

0.4.1 (2023-02-28)
------------------
* Organization Updates (`#72 <https://github.com/ros-industrial/ros_industrial_cmake_boilerplate/issues/72>`_)
  * Removed ricb subdirectory
  * Updated maintainer information
* Contributors: Michael Ripperger

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
