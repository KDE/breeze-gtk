cmake_minimum_required(VERSION 3.2)
project(breeze-gtk)

find_package(ECM 0.0.9 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_KDE_MODULE_DIR})
include(KDEInstallDirs)

add_subdirectory(Breeze-dark-gtk)
add_subdirectory(Breeze-gtk)
