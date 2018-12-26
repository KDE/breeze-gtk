add_custom_target(
    Breeze-dark-gtk ALL
    COMMAND ./build_theme.sh -c BreezeDark -t "${PROJECT_BINARY_DIR}/Breeze-Dark"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)

add_custom_target(
    Breeze-gtk ALL
    COMMAND ./build_theme.sh -c Breeze -t "${PROJECT_BINARY_DIR}/Breeze"
    COMMAND cp gtk-dark-3.18.css "${PROJECT_BINARY_DIR}/Breeze/gtk-3.18/gtk-dark.css"
    COMMAND cp gtk-dark-3.20.css "${PROJECT_BINARY_DIR}/Breeze/gtk-3.20/gtk-dark.css"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)

install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze-Dark" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
