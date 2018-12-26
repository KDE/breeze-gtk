add_custom_target(
    Breeze-dark-gtk ALL
    COMMAND ./build_theme.sh -c BreezeDark -t ../Breeze-dark-gtk
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)

add_custom_target(
    Breeze-gtk ALL
    COMMAND ./build_theme.sh -c Breeze -t ../Breeze-gtk
    COMMAND cp gtk-dark-3.18.css ../Breeze-gtk/gtk-3.18/gtk-dark.css
    COMMAND cp gtk-dark-3.20.css ../Breeze-gtk/gtk-3.20/gtk-dark.css
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/src"
)
