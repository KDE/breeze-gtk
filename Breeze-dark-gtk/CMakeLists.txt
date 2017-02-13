install(DIRECTORY gtk-2.0 DESTINATION ${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze-Dark
    ${directory_EXCLUDES})
install(DIRECTORY assets DESTINATION ${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze-Dark
        ${directory_EXCLUDES})

if (WITH_GTK3_VERSION VERSION_LESS "3.20")
install(FILES gtk-3.18/gtk.css DESTINATION ${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze-Dark/gtk-3.0/)
else()
install(FILES gtk-3.20/gtk.css DESTINATION ${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze-Dark/gtk-3.0/)
endif()
