file(GLOB_RECURSE SCSS_SOURCES "*.scss")
file(GLOB CSS_SOURCES "*.css")
file(GLOB_RECURSE GTK2_SOURCES "gtk2/*")

configure_file(build_theme.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/build_theme.sh @ONLY)

set(SOURCES
    ${SCSS_SOURCES}
    ${CSS_SOURCES}
    ${GTK2_SOURCES}
    render_assets.py
)

function(gen_targets THEME_NAME)
    set(THEME_DIR "${PROJECT_BINARY_DIR}/${THEME_NAME}")
    set(${THEME_NAME}_TARGETS
        "${THEME_DIR}/gtk-2.0/gtkrc"
        "${THEME_DIR}/gtk-3.0/gtk.css"
        PARENT_SCOPE
    )
endfunction()

gen_targets(Breeze)
gen_targets(Breeze-Dark)

list(APPEND Breeze_TARGETS
    "${PROJECT_BINARY_DIR}/Breeze/gtk-3.0/gtk-dark.css"
)

add_custom_command(
    OUTPUT ${Breeze-Dark_TARGETS}
    DEPENDS ${SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/build_theme.sh
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build_theme.sh -c BreezeDark -t "${PROJECT_BINARY_DIR}/Breeze-Dark" -r "${BREEZE_COLOR_INSTALL_ROOT}"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)
add_custom_target(Breeze-Dark ALL DEPENDS ${Breeze-Dark_TARGETS})

add_custom_command(
    OUTPUT ${Breeze_TARGETS}
    DEPENDS ${SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/build_theme.sh
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build_theme.sh -c BreezeLight -t "${PROJECT_BINARY_DIR}/Breeze" -r "${BREEZE_COLOR_INSTALL_ROOT}"
    COMMAND cp gtk-dark-3.0.css "${PROJECT_BINARY_DIR}/Breeze/gtk-3.0/gtk-dark.css"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)
add_custom_target(Breeze ALL DEPENDS ${Breeze_TARGETS})

install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
install(DIRECTORY "${PROJECT_BINARY_DIR}/Breeze-Dark" DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/")
install(FILES settings.ini DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze")
install(FILES settings.ini DESTINATION "${KDE_INSTALL_FULL_DATAROOTDIR}/themes/Breeze-Dark")
