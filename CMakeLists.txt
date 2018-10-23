project(breeze-gtk)
set(PROJECT_VERSION "5.14.2")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 2.8.12)

find_package(ECM 0.0.9 REQUIRED NO_MODULE)
include(FeatureSummary)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} "${CMAKE_SOURCE_DIR}/cmake")
find_package(GTKEngine)

include(KDEInstallDirs)

# Exclude these patterns when installing directories as they have no use
# in production.
set(directory_EXCLUDES
    PATTERN "render-assets.sh" EXCLUDE
    PATTERN "assets.svg" EXCLUDE
    PATTERN "assets.txt" EXCLUDE
)

add_subdirectory(Breeze-dark-gtk)
add_subdirectory(Breeze-gtk)
add_subdirectory(kconf_update)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
