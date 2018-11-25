find_package(Qt5 REQUIRED COMPONENTS Core)
include(KDEInstallDirs)

add_executable(gtkbreeze5.5 main.cpp)

target_link_libraries(gtkbreeze5.5 Qt5::Core)

install(TARGETS gtkbreeze5.5 DESTINATION ${LIB_INSTALL_DIR}/kconf_update_bin/)
install(FILES gtkbreeze5.5.upd DESTINATION ${KCONF_UPDATE_INSTALL_DIR})
