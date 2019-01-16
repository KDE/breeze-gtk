file(GLOB_RECURSE SCSS_SOURCES "*.scss")
file(GLOB CSS_SOURCES "*.css")
file(GLOB_RECURSE GTK2_SOURCES "gtk2/*")

set(SOURCES
    ${SCSS_SOURCES}
    ${CSS_SOURCES}
    ${GTK2_SOURCES}
    render_assets.py
    build_theme.sh
)

function(gen_targets THEME_NAME)
    set(THEME_DIR "${PROJECT_BINARY_DIR}/${THEME_NAME}")
    set(${THEME_NAME}_TARGETS
        "${THEME_DIR}/gtk-2.0/gtkrc"
        "${THEME_DIR}/gtk-3.18/gtk.css"
        "${THEME_DIR}/gtk-3.20/gtk.css"
        PARENT_SCOPE
    )
endfunction()

gen_targets(Breeze)
gen_targets(Breeze-Dark)

list(APPEND Breeze_TARGETS
    "${PROJECT_BINARY_DIR}/Breeze/gtk-3.18/gtk-dark.css"
    "${PROJECT_BINARY_DIR}/Breeze/gtk-3.20/gtk-dark.css"
)

add_custom_command(
    OUTPUT ${Breeze-Dark_TARGETS}
    DEPENDS ${SOURCES}
    COMMAND ./build_theme.sh -c BreezeDark -t "${PROJECT_BINARY_DIR}/Breeze-Dark" -r "${BREEZE_COLOR_INSTALL_ROOT}"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)
add_custom_target(Breeze-Dark ALL DEPENDS ${Breeze-Dark_TARGETS})

add_custom_command(
    OUTPUT ${Breeze_TARGETS}
    DEPENDS ${SOURCES}
    COMMAND ./build_theme.sh -c Breeze -t "${PROJECT_BINARY_DIR}/Breeze" -r "${BREEZE_COLOR_INSTALL_ROOT}"
    COMMAND cp gtk-dark-3.18.css "${PROJECT_BINARY_DIR}/Breeze/gtk-3.18/gtk-dark.css"
    COMMAND cp gtk-dark-3.20.css "${PROJECT_BINARY_DIR}/Breeze/gtk-3.20/gtk-dark.css"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)
add_custom_target(Breeze ALL DEPENDS ${Breeze_TARGETS})

install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze-Dark" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
