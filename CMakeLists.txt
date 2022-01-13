project(breeze-gtk)
set(PROJECT_VERSION "5.24.80")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 3.16)

find_package(ECM 0.0.9 REQUIRED NO_MODULE)
include(FeatureSummary)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH}  "${CMAKE_SOURCE_DIR}/cmake")
find_package(GTKEngine)
find_package(Sass REQUIRED)
find_package(PythonCairo)
set_package_properties(PythonCairo PROPERTIES TYPE REQUIRED PURPOSE "Required to render assets")
find_package(Breeze 5.14.90 REQUIRED)
set_package_properties(Breeze PROPERTIES TYPE REQUIRED PURPOSE "Required to build the Breeze GTK+ styles")


include(KDEInstallDirs)

add_subdirectory(src)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
