include(KDEInstallDirs)

set_package_properties(GTKEngine PROPERTIES
  DESCRIPTION "Pixmap/Pixbuf theme engine for GTK 2"
  URL "http://www.gtk.org/"
  TYPE RUNTIME
  PURPOSE "Required for GTK 2 theme")

set(_versions 2.20 2.18 2.16 2.14 2.12
   2.10  2.8  2.6  2.4  2.2 2.0
   1.20 1.18 1.16 1.14 1.12
   1.10  1.8  1.6  1.4  1.2 1.0)

foreach(_ver ${_versions})
  find_library(GTKPIXMAP_PLUGIN NAMES pixmap
    PATHS
    ${KDE_INSTALL_FULL_LIBDIR}/gtk-2.0/${_ver}.0/engines)
endforeach()

if(NOT ${GTKPIXMAP_PLUGIN} STREQUAL "GTKPIXMAP_PLUGIN-NOTFOUND")
  set(GTKEngine_FOUND TRUE)
endif()
