project(breeze-gtk)
set(PROJECT_VERSION "5.4.90")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 3.2)

find_package(ECM 0.0.9 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})
include(KDEInstallDirs)

add_subdirectory(Breeze-dark-gtk)
add_subdirectory(Breeze-gtk)
add_subdirectory(kconf_update)
